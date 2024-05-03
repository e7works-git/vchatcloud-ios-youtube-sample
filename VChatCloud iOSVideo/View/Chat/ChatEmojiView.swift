import SwiftUI

struct ChatEmojiView: View {
    @StateObject var chatResultModel: ChatResultModel
    
    var emojiAssetName: String {
        let pattern = "emo[0-9]+_[0-9]+"
        if let range = chatResultModel.message.range(of: pattern, options: .regularExpression) {
            return String(chatResultModel.message[range])
        } else {
            return ""
        }
    }
    
    var body: some View {
        Image(emojiAssetName)
    }
}

struct ChatEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        ChatEmojiView(chatResultModel: .MOCK)
    }
}
