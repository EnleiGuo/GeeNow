import Foundation
import SwiftUI

struct Source: Identifiable, Codable {
    let id: String
    let name: String
    let colorName: String
    var title: String?
    var type: SourceType = .hottest
    var interval: TimeInterval = 600
    var home: String?
    var column: Category?
    
    enum SourceType: String, Codable {
        case hottest
        case realtime
    }
    
    var color: Color {
        switch colorName {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "gray": return .gray
        case "slate": return Color(red: 0.44, green: 0.5, blue: 0.56)
        case "teal": return .teal
        case "indigo": return .indigo
        case "yellow": return .yellow
        case "emerald": return Color(red: 0.2, green: 0.83, blue: 0.6)
        default: return .accentColor
        }
    }
}

enum Category: String, CaseIterable, Identifiable, Codable {
    case focus = "关注"
    case hottest = "最热"
    case realtime = "实时"
    case china = "国内"
    case world = "国际"
    case tech = "科技"
    case finance = "财经"
    
    var id: String { rawValue }
}
