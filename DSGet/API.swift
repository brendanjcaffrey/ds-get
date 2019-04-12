import UIKit

class API: NSObject, URLSessionDelegate {
    private let loginURL =
        "https://%@/webapi/auth.cgi?api=SYNO.API.Auth&version=2&method=login&account=%@&passwd=%@&session=DownloadStation&format=sid"
    private let tasksURL = "https://%@/webapi/DownloadStation/task.cgi?api=SYNO.DownloadStation.Task&version=1&method=list&additional=transfer&sid=%@"
    private let deleteTaskURL =
        "https://%@//webapi/DownloadStation/task.cgi?api=SYNO.DownloadStation.Task&version=1&method=delete&sid=%@&id=%@&force_complete=false"

    private let opQueue = OperationQueue()
    private var session: URLSession?
    private var sessionID: String?
    private var host: String?

    override init() {
        super.init()
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: self.opQueue)
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust { // ignore SSL certificate errors
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    func login(values: Defaults.Values, onComplete:@escaping (_ success: Bool) -> Void) {
        let url = URL(string: String(format: loginURL, values.host, values.user, values.password))
        host = values.host
        spinnerOn()

        let task = session!.dataTask(with: url!) { data, _, error in
            self.spinnerOff()

            guard error == nil, let data = data else {
                onComplete(false)
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let data = json["data"] as? [String: Any], let sid = data["sid"] as? String {
                    self.sessionID = sid
                }
            }

            onComplete(self.sessionID != nil)
        }

        task.resume()
    }

    func getTasks(onComplete:@escaping (_ tasks: [Task]?) -> Void) {
        let url = URL(string: String(format: tasksURL, host!, sessionID!))
        spinnerOn()

        let task = session!.dataTask(with: url!) { data, _, error in
            self.spinnerOff()

            guard error == nil, let data = data else {
                onComplete(nil)
                return
            }

            onComplete(self.parseTasks(data))
        }

        task.resume()
    }

    func deleteTask(taskId: String, onComplete:@escaping (_ success: Bool) -> Void) {
        let url = URL(string: String(format: deleteTaskURL, host!, sessionID!, taskId))
        spinnerOn()

        let task = session!.dataTask(with: url!) { data, _, error in
            self.spinnerOff()

            guard error == nil, let data = data else {
                onComplete(false)
                return
            }

            var success = false
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let arr = json["data"] as? [Any], let data = arr[0] as? [String: Any], let error = data["error"] as? Int {
                    if error == 0 { success = true }
                }
            }

            onComplete(success)
        }

        task.resume()
    }

    private func parseTasks(_ data: Data) -> [Task]? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        guard let data = json["data"] as? [String: Any] else {
            return nil
        }
        guard let tasks = data["tasks"] as? [AnyObject] else {
            return nil
        }

        var parsedTasks: [Task] = []
        for task in tasks {
            if let task = task as? [String: Any] {
                parsedTasks.append(Task(task))
            }
        }
        return parsedTasks
    }

    private func spinnerOn() {
        DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = true }
    }

    private func spinnerOff() {
        DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
    }
}
