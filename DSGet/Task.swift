import Foundation

class Task {
    var taskId: String
    var status: String
    var title: String
    var totalSize: Int64
    var downloadedSize: Int64
    var downloadSpeed: Int64

    static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        formatter.isAdaptive = true
        return formatter
    }()

    init(_ json: [String: Any]) {
        taskId = json["id"] as? String ?? ""
        totalSize = (json["size"] as? NSNumber ?? 0).int64Value
        status = json["status"] as? String ?? ""
        title = json["title"] as? String ?? ""
        downloadedSize = 0
        downloadSpeed = 0

        if let additional = json["additional"] as? [String: Any], let transfer = additional["transfer"] as? [String: Any] {
            downloadedSize = (transfer["size_downloaded"] as? NSNumber ?? 0).int64Value
            downloadSpeed = (transfer["speed_download"] as? NSNumber ?? 0).int64Value
        }
    }

    func downloadSpeedString() -> String {
        return Task.byteFormatter.string(fromByteCount: downloadSpeed) + "/s"
    }

    func downloadPercentString() -> String {
        return Task.byteFormatter.string(fromByteCount: downloadedSize) + "/" + Task.byteFormatter.string(fromByteCount: totalSize)
            + " (" + percentComplete() + ")"
    }

    func downloadTotalString() -> String {
        return Task.byteFormatter.string(fromByteCount: totalSize)
    }

    func percentComplete() -> String {
        let percent = Double(downloadedSize) / Double(totalSize) * 100.0
        return String(format: "%.2f%%", percent)
    }

    func icon() -> String {
        switch status {
        case "waiting":             return "⏳"
        case "downloading":         return "⬇️"
        case "paused":              return "⏸"
        case "finished", "seeding": return "✅"
        case "error":               return "❌"
        default:                    return "❓"
        }
    }
}
