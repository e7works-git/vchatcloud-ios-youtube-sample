import SwiftUI

struct JoinUserView: View {
    @StateObject var chatResultModel: ChatResultModel

    var body: some View {
        HStack(spacing: 0) {
            Text("\(chatResultModel.nickname)")
            Text("님이 입장하셨습니다.")
        }
        .foregroundColor(Color(hex: 0x6f87c6))
        .font(.system(size: 14))
        .lineLimit(1)
        .padding(.horizontal)
    }
}

struct JoinUserView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            JoinUserView(chatResultModel: .MOCK)
                .background(Color.Theme.background)
            JoinUserView(chatResultModel: .MOCK)
                .background(Color.Theme.background)
            JoinUserView(chatResultModel: .MOCK)
                .background(Color.Theme.background)
        }
    }
}
