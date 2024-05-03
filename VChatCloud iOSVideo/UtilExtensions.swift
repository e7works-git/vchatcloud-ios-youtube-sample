import Foundation
import SwiftUI
import VChatCloudSwiftSDK

extension Color {
    init(hex: UInt, hexAlpha: Double? = nil, decAlpha: Double? = nil) {
        var alpha: Double
        if hexAlpha != nil {
            alpha = hexAlpha! / 0xff
        } else if decAlpha != nil {
            alpha = decAlpha!
        } else {
            alpha = 1
        }
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension String {
    var jsonToDict: Any {
        if let jsonData = self.data(using: .utf8) {
            do {
                let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: [])
                return dictionary
            } catch {
                debugPrint("this is not valid json: \(self)")
                return [:] as [String: Any]
            }
        }
        return [:] as [String: Any]
    }
}

extension Color {
    struct Theme {
        static var background = Color(hex: 0xdfe6f2)
    }
}

extension ChatroomViewModel {
    var personString: String {
        get {
            String(format: "%03d", arguments: [self.persons])
        }
    }
    
    var likeString: String {
        get {
            String(format: "%03d", arguments: [self.like])
        }
    }
}

// CachedAsyncImage set cache size
extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512_000_000, diskCapacity: 20_000_000_000)
}
