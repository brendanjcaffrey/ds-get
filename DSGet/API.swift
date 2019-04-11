import UIKit

class API: NSObject, URLSessionDelegate {
    private let loginURL =
        "https://%@/webapi/auth.cgi?api=SYNO.API.Auth&version=2&method=login&account=%@&passwd=%@&session=DownloadStation&format=sid"

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
        spinnerOn()

        let task = session!.dataTask(with: url!) { data, _, error in
            DispatchQueue.main.async { self.spinnerOff() }

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

    private func spinnerOn() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    private func spinnerOff() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
