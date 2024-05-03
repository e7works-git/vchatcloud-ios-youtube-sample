import SwiftUI

struct ChatHeaderView: View {
    @StateObject var chatResultModel: ChatResultModel

    var date: String {
        if Locale.current.language.languageCode == "ko" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일 E요일"
            return formatter.string(from: chatResultModel.messageDt)
        } else {
            return chatResultModel.messageDt.formatted(.dateTime.year().month().day().weekday())
        }
    }

    var body: some View {
        Text(date)
            .font(.system(size: 12))
            .frame(height: 24)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: 0xbec6d8))
            .foregroundColor(Color(hex: 0x333333))
            .cornerRadius(24)
    }
}

struct ChatHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ChatHeaderView(chatResultModel: ChatResultModel.MOCK)
        }
        .padding()
        .background(Color.Theme.background)
    }
}
