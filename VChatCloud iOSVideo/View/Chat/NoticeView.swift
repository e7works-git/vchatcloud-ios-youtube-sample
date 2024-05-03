import SwiftUI

struct NoticeView: View {
    @StateObject var chatResultModel: ChatResultModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
            }
            HStack(alignment: .top, spacing: 8) {
                Image("ico_entrynotice")
                Text(chatResultModel.message)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x999999))
            }
        }
        .padding(10)
        .background(Color(hex: 0xeeeeee))
        .cornerRadius(5)
    }
}

struct NoticeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NoticeView(chatResultModel: .MOCK)
            NoticeView(chatResultModel: .EMPTY)
        }
        .padding()
        .background(Color.Theme.background)
    }
}
