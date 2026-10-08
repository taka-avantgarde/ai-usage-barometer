import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    // NSWindow は NSApplication.shared が立ってから作る。格納プロパティで作ると
    // デリゲート生成時＝NSApp より前になり、起動時に落ちる。
    var floatPanel: FloatPanel!
    var detail: DetailWindow!
    var menuBar: MenuBarSurface?
    let dockGauge = GaugeView()
    var timer: Timer?

    func applicationDidFinishLaunching(_ note: Notification) {
        floatPanel = FloatPanel()
        detail = DetailWindow()

        dockGauge.axis = .vertical
        dockGauge.metrics = Gauge.dock
        // Dock タイルのビューは frame を持たないと何も描かれない
        dockGauge.frame = NSRect(x: 0, y: 0, width: 128, height: 128)
        NSApp.dockTile.contentView = dockGauge

        floatPanel.gauge.onClick = { [weak self] in self?.showDetail() }
        floatPanel.gauge.onRightClick = { [weak self] e in
            guard let self = self else { return }
            self.menu().popUp(positioning: nil,
                              at: self.floatPanel.gauge.convert(e.locationInWindow, from: nil),
                              in: self.floatPanel.gauge)
        }
        detail.gauge.onRightClick = { [weak self] e in
            guard let self = self else { return }
            self.menu().popUp(positioning: nil,
                              at: self.detail.gauge.convert(e.locationInWindow, from: nil),
                              in: self.detail.gauge)
        }

        applyPresence()
        refresh()
        restartTimer()
    }

    // 更新間隔はプラグインと同じ iv（1/3/5分）に従う。ここだけ 60 秒固定にすると、
    // 「設定は共有していて食い違わない」という前提がこの一点で崩れる。
    var interval: Int {
        let v = Int(Settings.read("iv", "3")) ?? 3
        return [1, 3, 5].contains(v) ? v : 3
    }

    func restartTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: Double(interval) * 60, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    // Dock のみのときは右クリックする相手がフローティングバーではなく Dock アイコンに
    // なる。ここを用意しないと設定にたどり着く道が消える。
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        menu()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showDetail()
        return true
    }

    // 居場所は3つ独立。全部消すと戻す手段まで消えるので、その時はバーを残す。
    struct Presence {
        var menubar: Bool
        var dock: Bool
        var float: Bool

        static func load() -> Presence {
            // 旧 presence キー（dock/float/both）からの引き継ぎ
            let legacy = Settings.read("presence", "both")
            var p = Presence(menubar: Settings.read("p_menu", "0") == "1",
                             dock: Settings.read("p_dock", legacy == "float" ? "0" : "1") == "1",
                             float: Settings.read("p_float", legacy == "dock" ? "0" : "1") == "1")
            if !p.menubar && !p.dock && !p.float { p.float = true }
            return p
        }
    }

    func applyPresence() {
        let p = Presence.load()
        if p.float {
            floatPanel.orderFrontRegardless()
        } else {
            floatPanel.orderOut(nil)
        }
        if p.menubar {
            if menuBar == nil {
                menuBar = MenuBarSurface()
                menuBar?.item.button?.target = self
                menuBar?.item.button?.action = #selector(statusClicked)
            }
        } else {
            menuBar?.remove()
            menuBar = nil
        }
        NSApp.setActivationPolicy(p.dock ? .regular : .accessory)
    }

    @objc func statusClicked() {
        guard let button = menuBar?.item.button else { return }
        menu().popUp(positioning: nil,
                     at: NSPoint(x: 0, y: button.bounds.height + 4),
                     in: button)
    }

    func refresh() {
        DispatchQueue.global(qos: .utility).async {
            let u = Plugin.fetch()
            DispatchQueue.main.async { self.apply(u) }
        }
    }

    func apply(_ u: Usage?) {
        var rows: [Row] = []
        var errors: [String] = []
        var update = false
        if let u = u {
            update = u.update.available
            for s in u.services {
                if !s.on { continue }
                if !s.error.isEmpty {
                    errors.append(s.name + ": " + s.error)
                    continue
                }
                for w in s.windows where w.show {
                    rows.append(Row(service: s.name,
                                    label: w.label,
                                    left: w.left,
                                    color: Gauge.color(w.color),
                                    resets: w.resets,
                                    pct: w.pct))
                }
            }
            if rows.isEmpty && errors.isEmpty {
                errors.append("Nothing selected — right-click for settings")
            }
        } else {
            errors.append("Cannot read " + Plugin.path)
        }
        var gauges = [floatPanel.gauge, detail.gauge, dockGauge]
        if let mb = menuBar { gauges.append(mb.gauge) }
        for g in gauges {
            g.rows = rows
            g.errors = errors
            g.updateAvailable = update
        }
        floatPanel.fit()
        detail.fit()
        menuBar?.update()
        NSApp.dockTile.display()
    }

    func showDetail() {
        detail.fit()
        if !detail.isVisible { detail.center() }
        detail.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // 設定はこのメニューが全部。別の設定画面は作らない。
    // 書き込み先はプラグインと共有の ~/.cache/claude-codex-bar/ で、
    // 書くのも --set 経由。どちらの表示から変えても食い違わない。
    func menu() -> NSMenu {
        let m = NSMenu()
        m.addItem(check("Show Claude", ["claude_on"]))
        m.addItem(check("Show Codex", ["codex_on"]))
        m.addItem(check("Percentages", ["c5p", "c7p", "cx5p", "cx7p"]))
        m.addItem(NSMenuItem.separator())

        let p = Presence.load()
        m.addItem(presenceItem("Menu bar", "p_menu", p.menubar))
        m.addItem(presenceItem("Dock icon", "p_dock", p.dock))
        m.addItem(presenceItem("Floating bar", "p_float", p.float))
        m.addItem(NSMenuItem.separator())

        let iv = NSMenuItem(title: "Refresh every", action: nil, keyEquivalent: "")
        let ivMenu = NSMenu()
        for minutes in [1, 3, 5] {
            let item = NSMenuItem(title: "\(minutes) min", action: #selector(setInterval(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = minutes
            item.state = interval == minutes ? .on : .off
            ivMenu.addItem(item)
        }
        iv.submenu = ivMenu
        m.addItem(iv)

        let login = NSMenuItem(title: "Open at login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        m.addItem(login)
        m.addItem(NSMenuItem.separator())

        let d = NSMenuItem(title: "Details…", action: #selector(showDetailAction), keyEquivalent: "")
        d.target = self
        m.addItem(d)

        let r = NSMenuItem(title: "Refresh now", action: #selector(refreshNow), keyEquivalent: "")
        r.target = self
        m.addItem(r)
        let q = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        // target を指定しないとキーウィンドウが無いとき無反応になる
        q.target = NSApp
        m.addItem(q)
        return m
    }

    private func check(_ title: String, _ keys: [String]) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(toggleKeys(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = keys
        item.state = Settings.read(keys[0], "1") == "1" ? .on : .off
        return item
    }

    @objc func toggleKeys(_ sender: NSMenuItem) {
        guard let keys = sender.representedObject as? [String], let first = keys.first else { return }
        let next = Settings.read(first, "1") == "1" ? "0" : "1"
        for k in keys { Plugin.set(k, next) }
        refresh()
    }

    private func presenceItem(_ title: String, _ key: String, _ on: Bool) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(togglePresence(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = key
        item.state = on ? .on : .off
        return item
    }

    @objc func togglePresence(_ sender: NSMenuItem) {
        guard let key = sender.representedObject as? String else { return }
        let now = sender.state == .on
        Settings.write(key, now ? "0" : "1")
        applyPresence()
        refresh()
    }

    @objc func setInterval(_ sender: NSMenuItem) {
        guard let minutes = sender.representedObject as? Int else { return }
        // 書くのは --set 経由。Codex ヘルパー側の間隔もプラグインが面倒を見る。
        Plugin.set("iv", String(minutes))
        restartTimer()
        refresh()
    }

    // ログイン項目は .app として動いているときだけ登録できる。swift run では
    // 失敗するが、それは異常ではないので黙って無視する。
    @objc func toggleLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            NSSound.beep()
        }
    }

    @objc func showDetailAction() {
        showDetail()
    }

    @objc func refreshNow() {
        refresh()
    }
}

// NSApp を先に立ててからデリゲートを作る。順序が逆だと起動時に落ちる。
let app = NSApplication.shared
let aibarDelegate = AppDelegate()
app.delegate = aibarDelegate
app.run()
