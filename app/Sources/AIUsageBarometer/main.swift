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
    var lastUsage: Usage?
    var isRefreshing = false
    var isUpdating = false

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
        NotificationCenter.default.addObserver(self, selector: #selector(screensChanged),
                                               name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    @objc func screensChanged() {
        floatPanel?.clampToVisibleScreen()
        updateFloatVisibility()
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
        item.menu = nil
        m.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 4), in: button)
    }

    func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        DispatchQueue.global(qos: .utility).async {
            let u = Plugin.fetch()
            DispatchQueue.main.async {
                self.isRefreshing = false
                self.apply(u)
            }
        }
    }

    static func semverIsNewer(_ candidate: String, than current: String) -> Bool {
        let cleanCandidate = candidate.hasPrefix("v") ? String(candidate.dropFirst()) : candidate
        let cleanCurrent = current.hasPrefix("v") ? String(current.dropFirst()) : current
        let cParts = cleanCandidate.split(separator: ".").compactMap { Int($0) }
        let curParts = cleanCurrent.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(cParts.count, curParts.count) {
            let c = i < cParts.count ? cParts[i] : 0
            let cur = i < curParts.count ? curParts[i] : 0
            if c > cur { return true }
            if c < cur { return false }
        }
        return false
    }

    func apply(_ u: Usage?) {
        if let u = u { self.lastUsage = u }
        var rows: [Row] = []
        var errors: [String] = []
        var update = false
        if let u = u {
            update = u.update.available
            latestVersion = u.update.latest
            if update && !latestVersion.isEmpty && Self.semverIsNewer(latestVersion, than: u.version) && !isUpdating && Settings.read("auto_updated_version", "") != latestVersion {
                Settings.write("auto_updated_version", latestVersion)
                post(title: "AI Usage Barometer " + latestVersion, body: "Updating automatically in the background…")
                installUpdate()
            }

            let clOn = Settings.read("claude_on", "1") == "1"
            let c5 = clOn && Settings.read("c5", "1") == "1"
            let c5p = Settings.read("c5p", "1") == "1"
            let c7 = clOn && Settings.read("c7", "1") == "1"
            let c7p = Settings.read("c7p", "1") == "1"

            let cxOn = Settings.read("codex_on", "1") == "1"
            let cx5 = cxOn && Settings.read("cx5", "1") == "1"
            let cx5p = Settings.read("cx5p", "1") == "1"
            let cx7 = cxOn && Settings.read("cx7", "1") == "1"
            let cx7p = Settings.read("cx7p", "1") == "1"

            let gmOn = Settings.read("gemini_on", "1") == "1"
            let gm5 = gmOn && Settings.read("gm5", "1") == "1"
            let gm5p = Settings.read("gm5p", "1") == "1"
            let gm7 = gmOn && Settings.read("gm7", "1") == "1"
            let gm7p = Settings.read("gm7p", "1") == "1"

            for s in u.services {
                let sOn: Bool
                switch s.name {
                case "Claude": sOn = clOn
                case "Codex": sOn = cxOn
                case "Gemini": sOn = gmOn
                default: sOn = s.on
                }
                if !sOn { continue }
                if !s.error.isEmpty {
                    errors.append(s.name + ": " + s.error)
                    continue
                }
                let ordered = s.windows.sorted { ($0.label == "5h" ? 0 : 1) < ($1.label == "5h" ? 0 : 1) }
                for w in ordered {
                    let dispLabel = (w.label == "7d" || w.label == "1w") ? "1w" : w.label
                    let show: Bool
                    let pct: Bool
                    switch (s.name, dispLabel) {
                    case ("Claude", "5h"): show = c5; pct = c5p
                    case ("Claude", "1w"): show = c7; pct = c7p
                    case ("Codex", "5h"): show = cx5; pct = cx5p
                    case ("Codex", "1w"): show = cx7; pct = cx7p
                    case ("Gemini", "5h"): show = gm5; pct = gm5p
                    case ("Gemini", "1w"): show = gm7; pct = gm7p
                    default: show = w.show; pct = w.pct
                    }
                    if !show { continue }
                    rows.append(Row(service: s.name,
                                    label: dispLabel,
                                    left: w.left,
                                    color: Gauge.color(w.color),
                                    resets: w.resets,
                                    pct: pct))
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
        m.minimumWidth = 328
        let item = NSMenuItem()
        let panel = SettingsPanelView(
            updateAvailable: floatPanel.gauge.updateAvailable ? latestVersion : "",
            onSave: { [weak self] draft, iv, loginOn in
                guard let self = self else { return }
                for (k, v) in draft {
                    Settings.write(k, v ? "1" : "0")
                }
                Settings.write("iv", String(iv))
                let service = SMAppService.mainApp
                let currentLogin = (service.status == .enabled)
                if loginOn != currentLogin {
                    try? (loginOn ? service.register() : service.unregister())
                }
                self.applyPresence()
                self.restartTimer()
                if let last = self.lastUsage {
                    self.apply(last)
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    Plugin.set("iv", String(iv))
                    let u = Plugin.fetch()
                    DispatchQueue.main.async { self.apply(u) }
                }
            },
            onUpdate: { [weak self] in
                self?.installUpdate()
            },
            onDetails: { [weak self] in
                self?.showDetail()
            },
            onRefresh: { [weak self] in
                self?.refresh()
            },
            onQuit: {
                NSApp.terminate(nil)
            }
        )
        item.view = panel
        m.addItem(item)
        return m
    }

    @objc func installUpdate() {
        guard !isUpdating else { return }
        isUpdating = true
        DispatchQueue.global(qos: .utility).async {
            Plugin.run(["--update"])
            DispatchQueue.main.async {
                self.isUpdating = false
                self.refresh()
            }
        }
    }
}

// ── iOS / macOS System Settings 風のトグルスイッチ＋Saveボタン付きパネル ──
final class SettingsPanelView: NSView {
    override var isFlipped: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    private var draft: [String: Bool] = [:]
    private var draftIv: Int = 3
    private var draftLogin: Bool = false
    private var savedFlash: Bool = false
    private let updateVersion: String
    private let onSave: ([String: Bool], Int, Bool) -> Void
    private let onUpdate: () -> Void
    private let onDetails: () -> Void
    private let onRefresh: () -> Void
    private let onQuit: () -> Void

    private struct HitZone {
        let rect: NSRect
        let action: () -> Void
    }
    private var hitZones: [HitZone] = []

    init(updateAvailable: String,
         onSave: @escaping ([String: Bool], Int, Bool) -> Void,
         onUpdate: @escaping () -> Void,
         onDetails: @escaping () -> Void,
         onRefresh: @escaping () -> Void,
         onQuit: @escaping () -> Void) {
        self.updateVersion = updateAvailable
        self.onSave = onSave
        self.onUpdate = onUpdate
        self.onDetails = onDetails
        self.onRefresh = onRefresh
        self.onQuit = onQuit

        let clOn = Settings.read("claude_on", "1") == "1"
        let c5 = clOn && Settings.read("c5", "1") == "1"
        let c7 = clOn && Settings.read("c7", "1") == "1"
        let clActive = c5 || c7

        let cxOn = Settings.read("codex_on", "1") == "1"
        let cx5 = cxOn && Settings.read("cx5", "1") == "1"
        let cx7 = cxOn && Settings.read("cx7", "1") == "1"
        let cxActive = cx5 || cx7

        let gmOn = Settings.read("gemini_on", "1") == "1"
        let gm5 = gmOn && Settings.read("gm5", "1") == "1"
        let gm7 = gmOn && Settings.read("gm7", "1") == "1"
        let gmActive = gm5 || gm7
        let p = AppDelegate.Presence.load()

        self.draft = [
            "claude_on": clActive,
            "c5": c5,
            "c5p": Settings.read("c5p", "1") == "1",
            "c7": c7,
            "c7p": Settings.read("c7p", "1") == "1",
            "codex_on": cxActive,
            "cx5": cx5,
            "cx5p": Settings.read("cx5p", "1") == "1",
            "cx7": cx7,
            "cx7p": Settings.read("cx7p", "1") == "1",
            "gemini_on": gmActive,
            "gm5": gm5,
            "gm5p": Settings.read("gm5p", "1") == "1",
            "gm7": gm7,
            "gm7p": Settings.read("gm7p", "1") == "1",
            "p_menu": p.menubar,
            "p_dock": p.dock,
            "p_float": p.float,
            "notify": Settings.read("notify", "1") == "1"
        ]
        let v = Int(Settings.read("iv", "3")) ?? 3
        self.draftIv = [1, 3, 5].contains(v) ? v : 3
        self.draftLogin = (SMAppService.mainApp.status == .enabled)

        let totalHeight: CGFloat = updateAvailable.isEmpty ? 628 : 668
        super.init(frame: NSRect(x: 0, y: 0, width: 328, height: totalHeight))
    }

    required init?(coder: NSCoder) { fatalError() }

    private func toggleKey(_ key: String) {
        let next = !(draft[key] ?? true)
        draft[key] = next
        switch (key, next) {
        case ("claude_on", false):
            draft["c5"] = false; draft["c7"] = false
        case ("claude_on", true):
            draft["c5"] = true; draft["c7"] = true
        case ("codex_on", false):
            draft["cx5"] = false; draft["cx7"] = false
        case ("codex_on", true):
            draft["cx5"] = true; draft["cx7"] = true
        case ("gemini_on", false):
            draft["gm5"] = false; draft["gm7"] = false
        case ("gemini_on", true):
            draft["gm5"] = true; draft["gm7"] = true
        case ("c5", true), ("c7", true):
            draft["claude_on"] = true
        case ("c5", false), ("c7", false):
            if !(draft["c5"] ?? false) && !(draft["c7"] ?? false) {
                draft["claude_on"] = false
            }
        case ("cx5", true), ("cx7", true):
            draft["codex_on"] = true
        case ("cx5", false), ("cx7", false):
            if !(draft["cx5"] ?? false) && !(draft["cx7"] ?? false) {
                draft["codex_on"] = false
            }
        case ("gm5", true), ("gm7", true):
            draft["gemini_on"] = true
        case ("gm5", false), ("gm7", false):
            if !(draft["gm5"] ?? false) && !(draft["gm7"] ?? false) {
                draft["gemini_on"] = false
            }
        case ("p_menu", false), ("p_dock", false), ("p_float", false):
            if !(draft["p_menu"] ?? false) && !(draft["p_dock"] ?? false) && !(draft["p_float"] ?? false) {
                draft["p_float"] = true
            }
        default:
            break
        }
        savedFlash = false
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        hitZones.removeAll()

        let bg = NSColor(srgbRed: 0.055, green: 0.063, blue: 0.078, alpha: 1.0) // #0E1014
        let cardBg = NSColor(srgbRed: 0.082, green: 0.094, blue: 0.122, alpha: 1.0) // #15181F
        let borderCol = NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.09)
        let hairlineCol = NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.07)
        let blueOn = NSColor(srgbRed: 0.039, green: 0.518, blue: 1.0, alpha: 1.0) // #0A84FF
        let switchOff = NSColor(srgbRed: 0.224, green: 0.224, blue: 0.239, alpha: 1.0) // #39393D
        let textPrimary = NSColor(srgbRed: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
        let textMuted = NSColor(srgbRed: 0.56, green: 0.59, blue: 0.65, alpha: 1.0)

        let outerPath = NSBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 2), xRadius: 12, yRadius: 12)
        bg.setFill()
        outerPath.fill()

        let padX: CGFloat = 12
        let cardW: CGFloat = bounds.width - padX * 2
        var y: CGFloat = 10

        func drawCard(yStart: CGFloat, height: CGFloat) {
            let r = NSRect(x: padX, y: yStart, width: cardW, height: height)
            let p = NSBezierPath(roundedRect: r, xRadius: 10, yRadius: 10)
            cardBg.setFill()
            p.fill()
            borderCol.setStroke()
            p.lineWidth = 1
            p.stroke()
        }

        func drawHairline(at yPos: CGFloat, indent: CGFloat = 0) {
            let line = NSBezierPath()
            line.move(to: NSPoint(x: padX + indent, y: yPos))
            line.line(to: NSPoint(x: padX + cardW, y: yPos))
            hairlineCol.setStroke()
            line.lineWidth = 1
            line.stroke()
        }

        func drawSwitch(x: CGFloat, yCenter: CGFloat, on: Bool, small: Bool = false, dimmed: Bool = false) {
            let w: CGFloat = small ? 38 : 42
            let h: CGFloat = small ? 22 : 24
            let rect = NSRect(x: x, y: yCenter - h / 2, width: w, height: h)
            let track = NSBezierPath(roundedRect: rect, xRadius: h / 2, yRadius: h / 2)
            let fill = on ? blueOn : switchOff
            (dimmed ? fill.withAlphaComponent(0.35) : fill).setFill()
            track.fill()

            let knobSize = h - 4
            let knobX = on ? (x + w - knobSize - 2) : (x + 2)
            let knobRect = NSRect(x: knobX, y: yCenter - knobSize / 2, width: knobSize, height: knobSize)
            let knob = NSBezierPath(ovalIn: knobRect)
            NSColor.white.withAlphaComponent(dimmed ? 0.5 : 1.0).setFill()
            knob.fill()
        }

        func drawServiceParentRow(title: String, dotHex: String, key: String, yPos: CGFloat) {
            let rowH: CGFloat = 36
            let on = draft[key] ?? true
            let rowRect = NSRect(x: padX, y: yPos, width: cardW, height: rowH)
            let midY = yPos + rowH / 2

            let dotRect = NSRect(x: padX + 12, y: midY - 4.5, width: 9, height: 9)
            let dot = NSBezierPath(ovalIn: dotRect)
            Gauge.color(dotHex).setFill()
            dot.fill()

            let attr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: on ? textPrimary : textMuted
            ]
            NSString(string: title).draw(at: NSPoint(x: padX + 28, y: midY - 8), withAttributes: attr)

            drawSwitch(x: padX + cardW - 54, yCenter: midY, on: on)
            hitZones.append(HitZone(rect: rowRect) { [weak self] in self?.toggleKey(key) })
        }

        func drawChildRow(title: String, key: String, pctKey: String, parentKey: String, yPos: CGFloat) {
            let rowH: CGFloat = 32
            let parentOn = draft[parentKey] ?? true
            let on = parentOn && (draft[key] ?? true)
            let pctOn = draft[pctKey] ?? true
            let midY = yPos + rowH / 2
            drawHairline(at: yPos, indent: 28)

            let attr: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: on ? .medium : .regular),
                .foregroundColor: on ? textPrimary : textMuted.withAlphaComponent(parentOn ? 0.85 : 0.45)
            ]
            NSString(string: title).draw(at: NSPoint(x: padX + 28, y: midY - 7.5), withAttributes: attr)

            // % バッジトグル
            let pctRect = NSRect(x: padX + cardW - 92, y: midY - 9.5, width: 32, height: 19)
            let pctPath = NSBezierPath(roundedRect: pctRect, xRadius: 9.5, yRadius: 9.5)
            let activePct = on && pctOn
            (activePct ? blueOn.withAlphaComponent(0.22) : NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.05)).setFill()
            pctPath.fill()
            (activePct ? blueOn.withAlphaComponent(0.75) : borderCol).setStroke()
            pctPath.lineWidth = 1
            pctPath.stroke()

            let pctAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 10.5, weight: .bold),
                .foregroundColor: activePct ? blueOn : textMuted.withAlphaComponent(0.6)
            ]
            NSString(string: "%").draw(at: NSPoint(x: pctRect.midX - 5, y: midY - 6.5), withAttributes: pctAttr)

            drawSwitch(x: padX + cardW - 50, yCenter: midY, on: on, small: true, dimmed: !parentOn)

            let mainHit = NSRect(x: padX, y: yPos, width: cardW - 96, height: rowH)
            let switchHit = NSRect(x: padX + cardW - 56, y: yPos, width: 56, height: rowH)
            hitZones.append(HitZone(rect: mainHit) { [weak self] in self?.toggleKey(key) })
            hitZones.append(HitZone(rect: switchHit) { [weak self] in self?.toggleKey(key) })
            hitZones.append(HitZone(rect: pctRect.insetBy(dx: -4, dy: -4)) { [weak self] in
                guard let self = self else { return }
                self.draft[pctKey] = !(self.draft[pctKey] ?? true)
                self.savedFlash = false
                self.needsDisplay = true
            })
        }

        // ── Card 1: Claude / Codex / Gemini ──
        let card1H: CGFloat = (36 + 32 + 32) * 3
        drawCard(yStart: y, height: card1H)

        drawServiceParentRow(title: "Claude", dotHex: "#C66D28", key: "claude_on", yPos: y)
        y += 36
        drawChildRow(title: "5h", key: "c5", pctKey: "c5p", parentKey: "claude_on", yPos: y)
        y += 32
        drawChildRow(title: "1w", key: "c7", pctKey: "c7p", parentKey: "claude_on", yPos: y)
        y += 32

        drawHairline(at: y)
        drawServiceParentRow(title: "Codex", dotHex: "#1A8BA6", key: "codex_on", yPos: y)
        y += 36
        drawChildRow(title: "5h", key: "cx5", pctKey: "cx5p", parentKey: "codex_on", yPos: y)
        y += 32
        drawChildRow(title: "1w", key: "cx7", pctKey: "cx7p", parentKey: "codex_on", yPos: y)
        y += 32

        drawHairline(at: y)
        drawServiceParentRow(title: "Gemini", dotHex: "#158F6A", key: "gemini_on", yPos: y)
        y += 36
        drawChildRow(title: "5h", key: "gm5", pctKey: "gm5p", parentKey: "gemini_on", yPos: y)
        y += 32
        drawChildRow(title: "1w", key: "gm7", pctKey: "gm7p", parentKey: "gemini_on", yPos: y)
        y += 32 + 8

        // ── Card 2: Placement & Preferences ──
        let prefRows: [(String, String)] = [
            ("Menu bar", "p_menu"),
            ("Dock icon", "p_dock"),
            ("Floating bar", "p_float"),
            ("Low-usage alerts", "notify")
        ]
        let card2H: CGFloat = CGFloat(prefRows.count + 2) * 32
        drawCard(yStart: y, height: card2H)

        for (idx, item) in prefRows.enumerated() {
            if idx > 0 { drawHairline(at: y, indent: 12) }
            let rowH: CGFloat = 32
            let midY = y + rowH / 2
            let on = draft[item.1] ?? false
            let attr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12.5, weight: .medium),
                .foregroundColor: on ? textPrimary : textMuted
            ]
            NSString(string: item.0).draw(at: NSPoint(x: padX + 12, y: midY - 7.5), withAttributes: attr)
            drawSwitch(x: padX + cardW - 50, yCenter: midY, on: on, small: true)
            let rowRect = NSRect(x: padX, y: y, width: cardW, height: rowH)
            let k = item.1
            hitZones.append(HitZone(rect: rowRect) { [weak self] in self?.toggleKey(k) })
            y += rowH
        }

        // Open at login row
        drawHairline(at: y, indent: 12)
        do {
            let rowH: CGFloat = 32
            let midY = y + rowH / 2
            let attr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12.5, weight: .medium),
                .foregroundColor: draftLogin ? textPrimary : textMuted
            ]
            NSString(string: "Open at login").draw(at: NSPoint(x: padX + 12, y: midY - 7.5), withAttributes: attr)
            drawSwitch(x: padX + cardW - 50, yCenter: midY, on: draftLogin, small: true)
            let rowRect = NSRect(x: padX, y: y, width: cardW, height: rowH)
            hitZones.append(HitZone(rect: rowRect) { [weak self] in
                guard let self = self else { return }
                self.draftLogin.toggle()
                self.savedFlash = false
                self.needsDisplay = true
            })
            y += rowH
        }

        // Refresh interval row (1m / 3m / 5m)
        drawHairline(at: y, indent: 12)
        do {
            let rowH: CGFloat = 32
            let midY = y + rowH / 2
            let attr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12.5, weight: .medium),
                .foregroundColor: textPrimary
            ]
            NSString(string: "Refresh every").draw(at: NSPoint(x: padX + 12, y: midY - 7.5), withAttributes: attr)

            let opts = [1, 3, 5]
            var bx = padX + cardW - 118
            for m in opts {
                let bRect = NSRect(x: bx, y: midY - 10, width: 34, height: 20)
                let bPath = NSBezierPath(roundedRect: bRect, xRadius: 6, yRadius: 6)
                let active = (draftIv == m)
                (active ? blueOn : switchOff).setFill()
                bPath.fill()
                let bAttr: [NSAttributedString.Key: Any] = [
                    .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .semibold),
                    .foregroundColor: active ? NSColor.white : textMuted
                ]
                NSString(string: "\(m)m").draw(at: NSPoint(x: bRect.midX - 8, y: midY - 7), withAttributes: bAttr)
                hitZones.append(HitZone(rect: bRect) { [weak self] in
                    self?.draftIv = m
                    self?.savedFlash = false
                    self?.needsDisplay = true
                })
                bx += 37
            }
            y += rowH + 10
        }

        // Optional update button
        if !updateVersion.isEmpty {
            let upRect = NSRect(x: padX, y: y, width: cardW, height: 30)
            let upPath = NSBezierPath(roundedRect: upRect, xRadius: 8, yRadius: 8)
            NSColor(srgbRed: 1.0, green: 0.62, blue: 0.04, alpha: 0.2).setFill()
            upPath.fill()
            let upAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: NSColor(srgbRed: 1.0, green: 0.62, blue: 0.04, alpha: 1.0)
            ]
            let upStr = "⬆ Update to \(updateVersion)"
            let sz = NSString(string: upStr).size(withAttributes: upAttr)
            NSString(string: upStr).draw(at: NSPoint(x: upRect.midX - sz.width / 2, y: upRect.midY - sz.height / 2), withAttributes: upAttr)
            hitZones.append(HitZone(rect: upRect) { [weak self] in
                self?.enclosingMenuItem?.menu?.cancelTracking()
                self?.onUpdate()
            })
            y += 38
        }

        // ── Primary Save Button ──
        let saveRect = NSRect(x: padX, y: y, width: cardW, height: 34)
        let savePath = NSBezierPath(roundedRect: saveRect, xRadius: 8, yRadius: 8)
        let saveCol = savedFlash
            ? NSColor(srgbRed: 0.082, green: 0.561, blue: 0.416, alpha: 1.0)
            : blueOn
        saveCol.setFill()
        savePath.fill()

        let saveTitle = savedFlash ? "Saved ✓" : "Save"
        let saveAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let saveSz = NSString(string: saveTitle).size(withAttributes: saveAttr)
        NSString(string: saveTitle).draw(
            at: NSPoint(x: saveRect.midX - saveSz.width / 2, y: saveRect.midY - saveSz.height / 2),
            withAttributes: saveAttr
        )
        hitZones.append(HitZone(rect: saveRect) { [weak self] in
            guard let self = self else { return }
            self.savedFlash = true
            self.needsDisplay = true
            self.onSave(self.draft, self.draftIv, self.draftLogin)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.enclosingMenuItem?.menu?.cancelTracking()
            }
        })
        y += 40

        // ── Footer Quick Actions (Details · Refresh · Quit) ──
        let actions: [(String, () -> Void)] = [
            ("Details…", { [weak self] in
                self?.enclosingMenuItem?.menu?.cancelTracking()
                self?.onDetails()
            }),
            ("Refresh now", { [weak self] in
                self?.enclosingMenuItem?.menu?.cancelTracking()
                self?.onRefresh()
            }),
            ("Quit", { [weak self] in
                self?.enclosingMenuItem?.menu?.cancelTracking()
                self?.onQuit()
            })
        ]
        let colW = cardW / CGFloat(actions.count)
        for (i, act) in actions.enumerated() {
            let r = NSRect(x: padX + CGFloat(i) * colW, y: y, width: colW, height: 24)
            let aAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 11.5, weight: .medium),
                .foregroundColor: textMuted
            ]
            let sz = NSString(string: act.0).size(withAttributes: aAttr)
            NSString(string: act.0).draw(
                at: NSPoint(x: r.midX - sz.width / 2, y: r.midY - sz.height / 2),
                withAttributes: aAttr
            )
            hitZones.append(HitZone(rect: r, action: act.1))
        }
    }

    override func mouseDown(with event: NSEvent) {
        let pt = convert(event.locationInWindow, from: nil)
        for zone in hitZones where zone.rect.contains(pt) {
            zone.action()
            return
        }
    }
}


// NSApp を先に立ててからデリゲートを作る。順序が逆だと起動時に落ちる。
let app = NSApplication.shared
let aibarDelegate = AppDelegate()
app.delegate = aibarDelegate
app.run()
