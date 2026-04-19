import UIKit

final class ThemeManager {

    static let shared = ThemeManager()

    private let darkModeKey = "isDarkModeEnabled"

    private init() {}

    var isDarkMode: Bool {
        UserDefaults.standard.bool(forKey: darkModeKey)
    }

    // Stores the dark mode preference and applies it immediately.
    func setDarkMode(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: darkModeKey)
        applyTheme()
    }

    // Applies the saved interface style to the app's main window.
    func applyTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}
