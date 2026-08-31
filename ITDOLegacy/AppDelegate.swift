import UIKit

/// Точка входа legacy-клиента.
///
/// Сознательно НЕ используется SwiftUI App / Scene lifecycle (UIScene,
/// UIWindowSceneDelegate) — оба появились в iOS 13, а этот таргет должен
/// стартовать на iOS 9. Вместо этого — классический
/// UIApplicationDelegate с ручным управлением UIWindow, как это делалось
/// до Scene-based lifecycle.
@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let root: UIViewController
        if KeychainStore.get(forKey: APIConfig.tokenKeychainKey) != nil {
            // TODO: заменить на реальный экран после логина, когда появится
            // legacy-порт основного функционала (чаты/лента и т.п.).
            root = UIViewController()
            root.view.backgroundColor = .white
        } else {
            root = LoginViewController()
        }
        window.rootViewController = UINavigationController(rootViewController: root)
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
