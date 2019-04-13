import Foundation

class Task: File {
    var taskId = ""
    var status = ""
    var downloadSpeed: Int64 = 0
    var files: [File] = []

    override init(_ json: [String: Any]) {
        super.init()

        taskId = json["id"] as? String ?? ""
        totalSize = (json["size"] as? NSNumber ?? 0).int64Value
        status = json["status"] as? String ?? ""
        title = json["title"] as? String ?? ""

        guard let additional = json["additional"] as? [String: Any] else { return }
        if let transfer = additional["transfer"] as? [String: Any] {
            downloadedSize = (transfer["size_downloaded"] as? NSNumber ?? 0).int64Value
            downloadSpeed = (transfer["speed_download"] as? NSNumber ?? 0).int64Value
        }

        guard let filesArr = additional["file"] as? [Any] else { return }
        for fileObj in filesArr {
            if let fileObj = fileObj as? [String: Any] {
                files.append(File(fileObj))
            }
        }
    }

    func downloadSpeedString() -> String {
        return File.byteFormatter.string(fromByteCount: downloadSpeed) + "/s"
    }

    func downloadTotalString() -> String {
        return File.byteFormatter.string(fromByteCount: totalSize)
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
