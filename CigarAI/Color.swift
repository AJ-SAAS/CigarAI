import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")) // Only trim '#'
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    static let appBackground = Color(hex: "#FDFAF2")   // Creamy off-white for ChatbotView
    static let backgroundCream = Color(hex: "#FEFBF3") // Light cream for AuthView background
    static let suggestedChip = Color(hex: "#FEF3E6")   // Light peach for suggested questions
    static let textDark = Color(hex: "#333333")        // Dark gray for text
}
