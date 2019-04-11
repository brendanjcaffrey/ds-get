import Foundation

class Task {
    var taskId: String
    var status: String
    var title: String
    var totalSize: Int64
    var downloadedSize: Int64

    init(_ json: [String: Any]) {
        taskId = json["id"] as? String ?? ""
        totalSize = (json["size"] as? NSNumber ?? 0).int64Value
        status = json["status"] as? String ?? ""
        title = json["title"] as? String ?? ""
        downloadedSize = 0

        if let additional = json["additional"] as? [String: Any], let transfer = additional["transfer"] as? [String: Any] {
            downloadedSize = (transfer["size_downloaded"] as? NSNumber ?? 0).int64Value
        }
    }
}
