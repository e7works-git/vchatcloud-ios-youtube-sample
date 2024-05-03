import SwiftUI

struct ChatWhisperView: View {
    @StateObject var chatResultModel: ChatResultModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
            }
            HStack(alignment: .top, spacing: 8) {
                Image("ico_whisper")
                VStack(alignment: .leading, spacing: 8) {
                    Text(chatResultModel.nickname)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: 0x666666))
                    +
                    Text(chatResultModel.isMe ? "님에게 귓속말" : "님의 귓속말")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x999999))
                    Text(chatResultModel.message)
                }
            }
        }
        .padding(10)
        .background(Color(hex: 0xeeeeee))
        .cornerRadius(5)
    }
}

struct ChatWhisperView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatWhisperView(chatResultModel: .MOCK)
            ChatWhisperView(chatResultModel: .EMPTY)
        }
    }
}
