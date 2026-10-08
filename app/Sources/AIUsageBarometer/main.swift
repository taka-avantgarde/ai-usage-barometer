import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    // NSWindow は NSApplication.shared が立ってから作る。格納プロパティで作ると
    // デリゲート生成時＝NSApp より前になり、起動時に落ちる。
    var floatPanel: FloatPanel!
    var detail: DetailWindow!
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
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
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

    func applyPresence() {
        let p = Settings.read("presence", "both")
        if p == "dock" {
            floatPanel.orderOut(nil)
        } else {
            floatPanel.orderFrontRegardless()
        }
        NSApp.setActivationPolicy(p == "float" ? .accessory : .regular)
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
        for g in [floatPanel.gauge, detail.gauge, dockGauge] {
            g.rows = rows
            g.errors = errors
            g.updateAvailable = update
        }
        floatPanel.fit()
        detail.fit()
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

        let presence = Settings.read("presence", "both")
        for (title, value) in [("Dock only", "dock"), ("Floating bar", "float"), ("Both", "both")] {
            let item = NSMenuItem(title: title, action: #selector(setPresence(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = value
            item.state = presence == value ? .on : .off
            m.addItem(item)
        }
        m.addItem(NSMenuItem.separator())

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

    @objc func setPresence(_ sender: NSMenuItem) {
        guard let v = sender.representedObject as? String else { return }
        Settings.write("presence", v)
        applyPresence()
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
