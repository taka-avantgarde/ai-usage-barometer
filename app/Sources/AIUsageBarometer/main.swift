import AppKit
import ServiceManagement
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    // NSWindow は NSApplication.shared が立ってから作る。格納プロパティで作ると
    // デリゲート生成時＝NSApp より前になり、起動時に落ちる。
    var floatPanel: FloatPanel!
    var detail: DetailWindow!
    var menuBar: MenuBarSurface?
    var firstRun: FirstRunWindow?
    let dockGauge = GaugeView()
    var timer: Timer?
    // 一度鳴らしたら、回復するまで黙る。鳴り続ける通知は無視されるだけ。
    var warned: Set<String> = []
    var latestVersion = ""

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

        // 全画面に入った／出たを拾う
        let wc = NSWorkspace.shared.notificationCenter
        wc.addObserver(self, selector: #selector(updateFloatVisibility),
                       name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
        wc.addObserver(self, selector: #selector(updateFloatVisibility),
                       name: NSWorkspace.didActivateApplicationNotification, object: nil)
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

    // 全画面アプリが前面のときはメニューバーの分だけ visibleFrame が縮まない。
    // これを目印に、作業中のアプリの上へ割り込まないようにする。
    var fullScreenActive: Bool {
        guard let s = NSScreen.main else { return false }
        return s.visibleFrame.height >= s.frame.height - 1
    }

    @objc func updateFloatVisibility() {
        guard floatPanel != nil else { return }
        let wanted = Presence.load().float && !fullScreenActive
        if wanted {
            if !floatPanel.isVisible { floatPanel.orderFrontRegardless() }
        } else if floatPanel.isVisible {
            floatPanel.orderOut(nil)
        }
    }

    func applyPresence() {
        let p = Presence.load()
        if p.float && !fullScreenActive {
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
        guard let item = menuBar?.item, let button = item.button else { return }
        let m = menu()
        item.menu = m
        button.performClick(nil)
        item.menu = nil
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
            latestVersion = u.update.latest
            if update && !latestVersion.isEmpty && Settings.read("auto_updated_version", "") != latestVersion {
                Settings.write("auto_updated_version", latestVersion)
                post(title: "AI Usage Barometer " + latestVersion, body: "Updating automatically in the background…")
                installUpdate()
            }
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

        notifyIfLow(rows)
        showFirstRunIfNeeded(rows)
    }

    // 残りが少なくなったら一度だけ報せる。10% を割ったら鳴らし、20% まで戻ったら
    // また鳴らせるようにする。境目で往復しても連打にならない。
    func notifyIfLow(_ rows: [Row]) {
        guard Settings.read("notify", "1") == "1" else { return }
        guard Bundle.main.bundleIdentifier != nil else { return }   // swift run では通知は使えない
        for r in rows {
            let key = r.service + "/" + r.label
            if r.left >= 0 && r.left <= 10 {
                if warned.contains(key) { continue }
                warned.insert(key)
                post(title: r.service + " " + r.label + " — " + String(r.left) + "% left",
                     body: r.resets.isEmpty ? "" : "recovers in " + r.resets)
            } else if r.left >= 20 {
                warned.remove(key)
            }
        }
    }

    private func post(title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            if !body.isEmpty { content.body = body }
            let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                content: content,
                                                trigger: nil)
            center.add(request, withCompletionHandler: nil)
        }
    }

    // 初回だけ。実データが1行でも取れてから出す（空の枠を見せても選べない）。
    func showFirstRunIfNeeded(_ rows: [Row]) {
        guard firstRun == nil, FirstRunWindow.needed, !rows.isEmpty else { return }
        let w = FirstRunWindow(rows: Array(rows.prefix(2))) { [weak self] key in
            for k in ["p_menu", "p_dock", "p_float"] { Settings.write(k, k == key ? "1" : "0") }
            self?.firstRun?.close()
            self?.firstRun = nil
            self?.applyPresence()
            self?.refresh()
        }
        firstRun = w
        w.center()
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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
        let clOn = Settings.read("claude_on", "1") == "1"
        let c5On = clOn && Settings.read("c5", "1") == "1"
        let c7On = clOn && Settings.read("c7", "1") == "1"
        let clActive = c5On || c7On
        m.addItem(serviceHeader("Claude", color: "#C66D28", key: "claude_on", on: clActive))
        m.addItem(windowRow("5h", key: "c5", on: c5On, parentOn: clActive))
        m.addItem(windowRow("1w (7d)", key: "c7", on: c7On, parentOn: clActive))

        let cxOn = Settings.read("codex_on", "1") == "1"
        let cx5On = cxOn && Settings.read("cx5", "1") == "1"
        let cx7On = cxOn && Settings.read("cx7", "1") == "1"
        let cxActive = cx5On || cx7On
        m.addItem(serviceHeader("Codex", color: "#1A8BA6", key: "codex_on", on: cxActive))
        m.addItem(windowRow("5h", key: "cx5", on: cx5On, parentOn: cxActive))
        m.addItem(windowRow("1w (7d)", key: "cx7", on: cx7On, parentOn: cxActive))

        let gmOn = Settings.read("gemini_on", "1") == "1" && Settings.read("gm5", "1") == "1"
        m.addItem(serviceHeader("Gemini", color: "#158F6A", key: "gemini_on", on: gmOn))
        m.addItem(windowRow("5h", key: "gm5", on: gmOn, parentOn: gmOn))
        m.addItem(NSMenuItem.separator())
        m.addItem(check("Show % numbers", ["c5p", "c7p", "cx5p", "cx7p", "gm5p"]))
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

        m.addItem(check("Low-usage alerts", ["notify"]))

        let login = NSMenuItem(title: "Open at login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        m.addItem(login)
        m.addItem(NSMenuItem.separator())

        // バーに矢印が出ているなら、ここから1クリックで終わらせられること。
        // 印だけ出して手順を読ませるのは、報せていないのと同じ。
        if floatPanel.gauge.updateAvailable && !latestVersion.isEmpty {
            let up = NSMenuItem(title: "Update to " + latestVersion,
                                action: #selector(installUpdate), keyEquivalent: "")
            up.target = self
            m.addItem(up)
            m.addItem(NSMenuItem.separator())
        }

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

    private func serviceHeader(_ title: String, color hex: String, key: String, on: Bool) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(toggleKeys(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = [key]
        item.state = on ? .on : .off
        let attr = NSMutableAttributedString(
            string: "●  ",
            attributes: [
                .foregroundColor: Gauge.color(hex),
                .font: NSFont.systemFont(ofSize: 11, weight: .bold)
            ]
        )
        attr.append(NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: on ? NSColor.labelColor : NSColor.secondaryLabelColor,
                .font: NSFont.systemFont(ofSize: 13, weight: .semibold)
            ]
        ))
        item.attributedTitle = attr
        return item
    }

    private func windowRow(_ title: String, key: String, on: Bool, parentOn: Bool) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(toggleKeys(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = [key]
        item.state = on ? .on : .off
        item.indentationLevel = 1
        item.attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: (on && parentOn) ? NSColor.labelColor : NSColor.secondaryLabelColor,
                .font: NSFont.monospacedDigitSystemFont(ofSize: 12.5, weight: on ? .medium : .regular)
            ]
        )
        return item
    }

    private func check(_ title: String, _ keys: [String], indent: Int = 0, on: Bool? = nil) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(toggleKeys(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = keys
        let isOn = on ?? (Settings.read(keys[0], "1") == "1")
        item.state = isOn ? .on : .off
        if indent > 0 { item.indentationLevel = indent }
        return item
    }

    @objc func toggleKeys(_ sender: NSMenuItem) {
        guard let keys = sender.representedObject as? [String] else { return }
        let next = sender.state == .on ? "0" : "1"
        for k in keys {
            Settings.write(k, next)
            switch (k, next) {
            case ("claude_on", "0"):
                Settings.write("c5", "0"); Settings.write("c7", "0")
            case ("claude_on", "1"):
                Settings.write("c5", "1"); Settings.write("c7", "1")
            case ("codex_on", "0"):
                Settings.write("cx5", "0"); Settings.write("cx7", "0")
            case ("codex_on", "1"):
                Settings.write("cx5", "1"); Settings.write("cx7", "1")
            case ("gemini_on", "0"):
                Settings.write("gm5", "0"); Settings.write("gm7", "0")
            case ("gemini_on", "1"):
                Settings.write("gm5", "1"); Settings.write("gm7", "1")
            case ("c5", "1"), ("c7", "1"):
                Settings.write("claude_on", "1")
            case ("c5", "0"), ("c7", "0"):
                if Settings.read("c5", "1") == "0" && Settings.read("c7", "1") == "0" {
                    Settings.write("claude_on", "0")
                }
            case ("cx5", "1"), ("cx7", "1"):
                Settings.write("codex_on", "1")
            case ("cx5", "0"), ("cx7", "0"):
                if Settings.read("cx5", "1") == "0" && Settings.read("cx7", "1") == "0" {
                    Settings.write("codex_on", "0")
                }
            case ("gm5", "1"):
                Settings.write("gemini_on", "1")
            case ("gm5", "0"):
                Settings.write("gemini_on", "0")
            default:
                break
            }
        }
        DispatchQueue.global(qos: .userInitiated).async {
            for k in keys { Plugin.set(k, next) }
            let u = Plugin.fetch()
            DispatchQueue.main.async { self.apply(u) }
        }
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

    @objc func installUpdate() {
        DispatchQueue.global(qos: .utility).async {
            Plugin.run(["--update"])
            DispatchQueue.main.async { self.refresh() }
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
