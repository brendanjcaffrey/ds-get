import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static var launchURL: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = UINavigationController(rootViewController: LoginViewController())
        window!.makeKeyAndVisible()

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.textOnBackground]
        UINavigationBar.appearance().tintColor = Colors.textOnBackground
        UINavigationBar.appearance().barTintColor = Colors.background
        UINavigationBar.appearance().isTranslucent = false

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.absoluteString.isEmpty {
            AppDelegate.launchURL = nil
            return false
        } else {
            AppDelegate.launchURL = url.absoluteString
            return true
        }
    }
}
