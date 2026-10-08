import AppKit

// 最前面の小さなバー。メニューバーと違い、居場所はアプリが持つ。
final class FloatPanel: NSPanel {
    let gauge = GaugeView()

    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 320, height: 34),
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)
        isFloatingPanel = true
        level = .statusBar
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        // 全画面アプリの上には出さない。作業の邪魔をしない。
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        gauge.axis = .grouped
        gauge.metrics = Gauge.float
        contentView = gauge
        restorePosition()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(savePosition),
                                               name: NSWindow.didMoveNotification,
                                               object: self)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func fit() {
        var f = frame
        let s = gauge.desiredSize
        // 左上を固定したまま伸縮させる（下に伸びると位置が動いて見える）
        f.origin.y += f.size.height - s.height
        f.size = s
        setFrame(f, display: true)
    }

    @objc private func savePosition() {
        Settings.write("float_x", String(format: "%.0f", frame.origin.x))
        Settings.write("float_y", String(format: "%.0f", frame.origin.y))
    }

    private func restorePosition() {
        if let x = Double(Settings.read("float_x", "")), let y = Double(Settings.read("float_y", "")) {
            setFrameOrigin(NSPoint(x: x, y: y))
            return
        }
        if let screen = NSScreen.main {
            let v = screen.visibleFrame
            setFrameOrigin(NSPoint(x: v.maxX - frame.width - 24, y: v.maxY - frame.height - 24))
        }
    }
}

// クリックで出る詳細。同じレンダラーを縦に使う。
final class DetailWindow: NSWindow {
    let gauge = GaugeView()

    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 300, height: 180),
                   styleMask: [.titled, .closable, .fullSizeContentView],
                   backing: .buffered,
                   defer: false)
        title = "AI Usage"
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        backgroundColor = NSColor(srgbRed: 0.1255, green: 0.1451, blue: 0.1686, alpha: 1.0)
        gauge.axis = .vertical
        gauge.metrics = Gauge.panel
        gauge.drawsBackground = false
        contentView = gauge
    }

    func fit() {
        setContentSize(gauge.desiredSize)
    }
}
