import AppKit

struct Row {
    let service: String
    let label: String
    let left: Int
    let color: NSColor
    let resets: String
    let pct: Bool
}

// 表面（Dock・Float・パネル）が3つあっても、描くのはこの1つだけ。
// 寸法だけ差し替える。見た目がズレる余地を作らない。
enum Gauge {
    static let bg = NSColor(srgbRed: 0.1255, green: 0.1451, blue: 0.1686, alpha: 0.94)
    static let fg = NSColor(srgbRed: 0.92, green: 0.94, blue: 0.96, alpha: 1.0)
    static let dim = NSColor(white: 0.55, alpha: 1.0)
    static let accent = NSColor(srgbRed: 1.0, green: 0.624, blue: 0.039, alpha: 1.0)

    struct Metrics {
        var barW: CGFloat
        var barH: CGFloat
        var rowH: CGFloat
        var pad: CGFloat
        var gap: CGFloat
        var corner: CGFloat
        var font: NSFont
        var small: NSFont
        var showService: Bool
        var showResets: Bool
        var pctSuffix: Bool
        // Dock タイルは大きさが決め打ちで、こちらが伸び縮みする側になる。
        var fitWidth: Bool
    }

    static var float: Metrics {
        Metrics(barW: 40, barH: 9, rowH: 19, pad: 9, gap: 10, corner: 10,
                font: NSFont.systemFont(ofSize: 11, weight: .medium),
                small: NSFont.systemFont(ofSize: 9),
                showService: true, showResets: false, pctSuffix: true, fitWidth: false)
    }

    // メニューバーは高さ22ptしかない。背景の暗い下地は DESIGN.md の通り残す
    // （半透明の明るいメニューバー上で、サービス色を読める状態に保つため）。
    static var menubar: Metrics {
        Metrics(barW: 30, barH: 8, rowH: 14, pad: 4, gap: 8, corner: 5,
                font: NSFont.systemFont(ofSize: 10, weight: .medium),
                small: NSFont.systemFont(ofSize: 8),
                showService: false, showResets: false, pctSuffix: false, fitWidth: false)
    }

    static var dock: Metrics {
        Metrics(barW: 54, barH: 13, rowH: 27, pad: 9, gap: 6, corner: 22,
                font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold),
                small: NSFont.systemFont(ofSize: 9),
                showService: false, showResets: false, pctSuffix: false, fitWidth: true)
    }

    static var panel: Metrics {
        Metrics(barW: 150, barH: 11, rowH: 36, pad: 16, gap: 10, corner: 12,
                font: NSFont.systemFont(ofSize: 13, weight: .medium),
                small: NSFont.systemFont(ofSize: 10),
                showService: true, showResets: true, pctSuffix: true, fitWidth: false)
    }

    static func color(_ hex: String) -> NSColor {
        var t = hex.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("#") { t.removeFirst() }
        guard t.count == 6, let v = UInt32(t, radix: 16) else { return fg }
        return NSColor(srgbRed: CGFloat((v >> 16) & 0xFF) / 255.0,
                       green: CGFloat((v >> 8) & 0xFF) / 255.0,
                       blue: CGFloat(v & 0xFF) / 255.0,
                       alpha: 1.0)
    }

    static func width(_ s: String, _ f: NSFont) -> CGFloat {
        (s as NSString).size(withAttributes: [.font: f]).width
    }

    @discardableResult
    static func text(_ s: String, _ p: NSPoint, _ f: NSFont, _ c: NSColor) -> CGFloat {
        let a: [NSAttributedString.Key: Any] = [.font: f, .foregroundColor: c]
        (s as NSString).draw(at: p, withAttributes: a)
        return (s as NSString).size(withAttributes: a).width
    }

    // 入りきらない文字は切り詰める。Dock の幅は固定なので、はみ出させない。
    static func text(_ s: String, in r: NSRect, _ f: NSFont, _ c: NSColor) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        (s as NSString).draw(in: r, withAttributes: [.font: f, .foregroundColor: c, .paragraphStyle: style])
    }

    // 塗りが残量、点々が消費分。DESIGN.md のバッテリー式をそのまま持ってくる。
    static func bar(_ r: NSRect, left: Int, color: NSColor) {
        let v = max(0, min(100, left))
        let w = r.width * CGFloat(v) / 100.0
        color.setFill()
        if w >= 1 {
            NSBezierPath(roundedRect: NSRect(x: r.minX, y: r.minY, width: w, height: r.height),
                         xRadius: 2.5, yRadius: 2.5).fill()
        }
        let pitch: CGFloat = 2.2
        let dot: CGFloat = 0.9
        var x = r.minX + w + 1.4
        while x < r.maxX - dot {
            var y = r.minY + 0.6
            var n = 0
            while y < r.maxY - dot {
                let xx = x + (n % 2 == 1 ? pitch / 2 : 0)
                if xx < r.maxX - dot {
                    NSBezierPath(rect: NSRect(x: xx, y: y, width: dot, height: dot)).fill()
                }
                y += pitch
                n += 1
            }
            x += pitch
        }
    }

    // 更新の印。文字ではなくパスで描く（表示を落とさないため）。
    static func arrow(at p: NSPoint) {
        accent.setFill()
        let t = NSBezierPath()
        t.move(to: NSPoint(x: p.x, y: p.y + 5))
        t.line(to: NSPoint(x: p.x + 4, y: p.y + 11))
        t.line(to: NSPoint(x: p.x + 8, y: p.y + 5))
        t.close()
        t.fill()
        NSBezierPath(rect: NSRect(x: p.x + 2.6, y: p.y, width: 2.8, height: 5.2)).fill()
    }
}

final class GaugeView: NSView {
    enum Axis {
        case horizontal
        case vertical
        // サービスごとに1行。Claude が上、Codex が下。
        case grouped
    }

    var rows: [Row] = [] { didSet { needsDisplay = true } }
    var errors: [String] = [] { didSet { needsDisplay = true } }
    var updateAvailable = false { didSet { needsDisplay = true } }
    var axis: Axis = .horizontal
    var metrics = Gauge.float
    var drawsBackground = true
    var onClick: (() -> Void)?
    var onRightClick: ((NSEvent) -> Void)?

    private var dragged = false

    private func pctText(_ r: Row) -> String {
        if r.left < 0 { return "--" }
        return metrics.pctSuffix ? "\(r.left)%" : "\(r.left)"
    }

    private func label(_ r: Row) -> String {
        metrics.showService ? r.service + " " + r.label : r.label
    }

    private var labelColumn: CGFloat {
        var w: CGFloat = 0
        for r in rows { w = max(w, Gauge.width(label(r), metrics.font)) }
        return w
    }

    private var pctColumn: CGFloat {
        var w: CGFloat = 0
        for r in rows where r.pct {
            w = max(w, Gauge.width(metrics.pctSuffix ? "100%" : "100", metrics.font))
        }
        return w
    }

    // 並び順を保ったままサービスでまとめる
    private func groups() -> [(String, [Row])] {
        var order: [String] = []
        var map: [String: [Row]] = [:]
        for r in rows {
            if map[r.service] == nil {
                order.append(r.service)
                map[r.service] = []
            }
            map[r.service]?.append(r)
        }
        return order.map { ($0, map[$0] ?? []) }
    }

    private func windowCellWidth(_ r: Row) -> CGFloat {
        var w = Gauge.width(r.label, metrics.font) + 4 + metrics.barW
        if r.pct { w += 4 + Gauge.width("100%", metrics.font) }
        return w
    }

    var desiredSize: NSSize {
        let m = metrics
        if axis == .grouped {
            let gs = groups()
            var serviceCol: CGFloat = 0
            for g in gs { serviceCol = max(serviceCol, Gauge.width(g.0, m.font)) }
            var widest: CGFloat = 0
            for g in gs {
                var w: CGFloat = 0
                for r in g.1 { w += windowCellWidth(r) + m.gap }
                widest = max(widest, max(0, w - m.gap))
            }
            for e in errors { widest = max(widest, Gauge.width(e, m.font) - serviceCol - 8) }
            var w = m.pad * 2 + serviceCol + 8 + widest
            if updateAvailable { w += 14 }
            let h = m.pad * 2 + CGFloat(gs.count + errors.count) * m.rowH
            // 中身のぶんだけの幅にする。枠を消したら、その分だけ必ず縮む。
            // 最低幅は「描くものが何も無いとき」にだけ要る。
            let empty = rows.isEmpty && errors.isEmpty
            return NSSize(width: empty ? 140 : w, height: max(h, 36))
        }
        if axis == .horizontal {
            var w = m.pad * 2
            if updateAvailable { w += 14 }
            var first = true
            for r in rows {
                if !first { w += m.gap }
                w += Gauge.width(label(r), m.font) + 6 + m.barW
                if r.pct { w += 6 + Gauge.width("100%", m.font) }
                first = false
            }
            for e in errors {
                if !first { w += m.gap }
                w += Gauge.width(e, m.font)
                first = false
            }
            let empty = rows.isEmpty && errors.isEmpty
            return NSSize(width: empty ? 140 : w, height: m.rowH + m.pad * 2)
        }
        let h = max(m.pad * 2 + CGFloat(rows.count + errors.count) * m.rowH, 60)
        var w = labelColumn + 8 + m.barW
        let p = pctColumn
        if p > 0 { w += 8 + p }
        for e in errors { w = max(w, Gauge.width(e, m.font)) }
        let empty = rows.isEmpty && errors.isEmpty
        return NSSize(width: empty ? 240 : w + m.pad * 2, height: h)
    }

    override func draw(_ dirtyRect: NSRect) {
        let m = metrics
        if drawsBackground {
            Gauge.bg.setFill()
            NSBezierPath(roundedRect: bounds, xRadius: m.corner, yRadius: m.corner).fill()
        }
        switch axis {
        case .horizontal: drawHorizontal()
        case .vertical: drawVertical()
        case .grouped: drawGrouped()
        }
    }

    private func drawHorizontal() {
        let m = metrics
        var x = m.pad
        if updateAvailable {
            Gauge.arrow(at: NSPoint(x: x, y: bounds.midY - 5))
            x += 14
        }
        let cy = bounds.midY
        let baseline = cy - m.font.pointSize * 0.58
        for r in rows {
            x += Gauge.text(label(r), NSPoint(x: x, y: baseline), m.font, Gauge.fg) + 6
            Gauge.bar(NSRect(x: x, y: cy - m.barH / 2, width: m.barW, height: m.barH),
                      left: r.left, color: r.color)
            x += m.barW
            if r.pct {
                x += 6
                x += Gauge.text(pctText(r), NSPoint(x: x, y: baseline), m.font, Gauge.fg)
            }
            x += m.gap
        }
        for e in errors {
            x += Gauge.text(e, NSPoint(x: x, y: baseline), m.font, Gauge.accent) + m.gap
        }
    }

    // サービスを1行にまとめる。Claude が上、Codex が下。枠はその行の中に横並び。
    // バーは短くてよい。読み取るのは色と残量の比で、長さそのものではない。
    private func drawGrouped() {
        let m = metrics
        var leftX = m.pad
        if updateAvailable {
            Gauge.arrow(at: NSPoint(x: leftX, y: bounds.midY - 5))
            leftX += 14
        }
        let gs = groups()
        var serviceCol: CGFloat = 0
        for g in gs { serviceCol = max(serviceCol, Gauge.width(g.0, m.font)) }
        let total = CGFloat(gs.count + errors.count) * m.rowH
        var y = bounds.midY + total / 2
        for g in gs {
            y -= m.rowH
            let cy = y + m.rowH * 0.5
            let baseline = cy - m.font.pointSize * 0.58
            Gauge.text(g.0, NSPoint(x: leftX, y: baseline), m.font, Gauge.dim)
            var x = leftX + serviceCol + 8
            for r in g.1 {
                x += Gauge.text(r.label, NSPoint(x: x, y: baseline), m.font, Gauge.fg) + 4
                Gauge.bar(NSRect(x: x, y: cy - m.barH / 2, width: m.barW, height: m.barH),
                          left: r.left, color: r.color)
                x += m.barW
                if r.pct {
                    x += 4
                    x += Gauge.text(pctText(r), NSPoint(x: x, y: baseline), m.font, Gauge.fg)
                }
                x += m.gap
            }
        }
        for e in errors {
            y -= m.rowH
            Gauge.text(e, in: NSRect(x: leftX, y: y + m.rowH * 0.3,
                                     width: bounds.maxX - m.pad - leftX, height: m.rowH * 0.7),
                       m.font, Gauge.accent)
        }
    }

    // 縦並びは列で揃える。ラベルは左、％は右端ぞろえ、バーは残り全部。
    // Dock タイルのように幅が決まっている面でも、はみ出さず端まで使い切る。
    private func drawVertical() {
        let m = metrics
        let left = m.pad
        let right = bounds.maxX - m.pad
        let avail = right - left
        let lw = labelColumn
        let pw = pctColumn
        var barW = m.barW
        if m.fitWidth {
            barW = max(18, avail - lw - 8 - (pw > 0 ? pw + 8 : 0))
        }
        // 更新の印は角のバッジにする。行の幅を食わせない。
        if updateAvailable {
            Gauge.arrow(at: NSPoint(x: right - 8, y: bounds.maxY - m.pad - 11))
        }
        let total = CGFloat(rows.count + errors.count) * m.rowH
        var y = bounds.midY + total / 2
        for r in rows {
            y -= m.rowH
            let hasNote = m.showResets && !r.resets.isEmpty
            let cy = y + (hasNote ? m.rowH * 0.66 : m.rowH * 0.5)
            let baseline = cy - m.font.pointSize * 0.58
            Gauge.text(label(r), NSPoint(x: left, y: baseline), m.font, Gauge.fg)
            Gauge.bar(NSRect(x: left + lw + 8, y: cy - m.barH / 2, width: barW, height: m.barH),
                      left: r.left, color: r.color)
            if r.pct {
                let t = pctText(r)
                Gauge.text(t, NSPoint(x: right - Gauge.width(t, m.font), y: baseline), m.font, Gauge.fg)
            }
            if hasNote {
                Gauge.text("recovers in " + r.resets, NSPoint(x: left, y: y + 2), m.small, Gauge.dim)
            }
        }
        for e in errors {
            y -= m.rowH
            Gauge.text(e, in: NSRect(x: left, y: y + m.rowH * 0.3, width: avail, height: m.rowH * 0.7),
                       m.font, Gauge.accent)
        }
    }

    override func mouseDown(with event: NSEvent) {
        dragged = false
    }

    override func mouseDragged(with event: NSEvent) {
        dragged = true
        window?.performDrag(with: event)
    }

    override func mouseUp(with event: NSEvent) {
        if !dragged { onClick?() }
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick?(event)
    }
}
