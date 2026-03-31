import UIKit

final class ThemeManager {

    static let shared = ThemeManager()

    private let darkModeKey = "isDarkModeEnabled"

    private init() {}

    var isDarkMode: Bool {
        UserDefaults.standard.bool(forKey: darkModeKey)
    }

    func setDarkMode(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: darkModeKey)
        applyTheme()
    }

    func applyTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}
