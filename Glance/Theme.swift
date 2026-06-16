import SwiftUI
import UIKit

enum Theme {
    static let bg        = dynamic(dark: .black,                                light: UIColor(white: 0.96, alpha: 1))
    static let card      = dynamic(dark: UIColor(white: 1, alpha: 0.06),        light: UIColor(white: 0, alpha: 0.04))
    static let stroke    = dynamic(dark: UIColor(white: 1, alpha: 0.10),        light: UIColor(white: 0, alpha: 0.10))
    static let primary   = dynamic(dark: .white,                               light: UIColor(red: 0.07, green: 0.08, blue: 0.11, alpha: 1))
    static let secondary = dynamic(dark: UIColor(white: 1, alpha: 0.60),        light: UIColor(white: 0, alpha: 0.55))
    static let accent    = dynamic(dark:  UIColor(red: 0.39, green: 0.71, blue: 1.00, alpha: 1),
                                   light: UIColor(red: 0.13, green: 0.45, blue: 0.90, alpha: 1))

    /// A color that resolves to the right value for the active light/dark trait.
    private static func dynamic(dark: UIColor, light: UIColor) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }
}

enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "Auto"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
