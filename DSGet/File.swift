import Foundation

class File {
    var title = ""
    var totalSize: Int64 = 0
    var downloadedSize: Int64 = 0

    static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        formatter.isAdaptive = true
        return formatter
    }()

    init() {
    }

    init(_ json: [String: Any]) {
        title = json["filename"] as? String ?? ""
        totalSize = (json["size"] as? NSNumber ?? 0).int64Value
        downloadedSize = (json["size_downloaded"] as? NSNumber ?? 0).int64Value
    }

    func downloadPercentString() -> String {
        return File.byteFormatter.string(fromByteCount: downloadedSize) + "/" + File.byteFormatter.string(fromByteCount: totalSize)
            + " (" + percentComplete() + ")"
    }

    func percentComplete() -> String {
        let percent = Double(downloadedSize) / Double(totalSize) * 100.0
        return String(format: "%.2f%%", percent)
    }
}
