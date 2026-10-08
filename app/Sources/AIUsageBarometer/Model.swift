import Foundation

// claude-codex.60s.sh --json が唯一のデータ層。認証・バックオフ・設定・Codex 解析は
// すべてあちら側にある。ここで判断を二重に持たない。
struct Usage: Decodable {
    struct Update: Decodable {
        let available: Bool
        let latest: String
    }
    struct Window: Decodable {
        let label: String
        let left: Int
        let color: String
        let resets: String
        let show: Bool
        let pct: Bool
    }
    struct Service: Decodable {
        let name: String
        let on: Bool
        let error: String
        let color: String
        let credits: String
        let windows: [Window]
    }
    let version: String
    let update: Update
    let updated: String
    let services: [Service]
}

enum Plugin {
    static var path: String {
        let fm = FileManager.default
        var candidates: [String] = []
        if let e = ProcessInfo.processInfo.environment["AIBAR_PLUGIN"] { candidates.append(e) }
        candidates.append(NSHomeDirectory() + "/SwiftBar/claude-codex.60s.sh")
        let cwd = fm.currentDirectoryPath
        candidates.append(cwd + "/claude-codex.60s.sh")
        candidates.append(cwd + "/../claude-codex.60s.sh")
        for c in candidates where fm.isReadableFile(atPath: c) { return c }
        return candidates[candidates.count - 1]
    }

    @discardableResult
    static func run(_ args: [String]) -> Data? {
        let p = Process()
        let script = path
        p.executableURL = URL(fileURLWithPath: "/bin/bash")
        p.arguments = [script] + args
        var env = ProcessInfo.processInfo.environment
        // ヘルパー解決と更新チェックはこの変数の有無で決まる
        env["SWIFTBAR_PLUGIN_PATH"] = script
        p.environment = env
        let out = Pipe()
        p.standardOutput = out
        p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return nil }
        let data = out.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return data
    }

    static func fetch() -> Usage? {
        guard let d = run(["--json"]), !d.isEmpty else { return nil }
        return try? JSONDecoder().decode(Usage.self, from: d)
    }

    static func set(_ key: String, _ value: String) {
        run(["--set", key, value])
    }
}

enum Settings {
    static let dir = NSHomeDirectory() + "/.cache/claude-codex-bar"

    static func read(_ key: String, _ fallback: String) -> String {
        let url = URL(fileURLWithPath: dir + "/" + key)
        guard let s = try? String(contentsOf: url, encoding: .utf8) else { return fallback }
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? fallback : t
    }

    static func write(_ key: String, _ value: String) {
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        try? (value + "\n").write(to: URL(fileURLWithPath: dir + "/" + key),
                                  atomically: true, encoding: .utf8)
    }
}
