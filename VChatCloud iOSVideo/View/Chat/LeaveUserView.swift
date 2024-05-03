import SwiftUI

struct LeaveUserView: View {
    @StateObject var chatResultModel: ChatResultModel

    var body: some View {
        HStack(spacing: 0) {
            Text("\(chatResultModel.nickname)")
            Text("님이 나갔습니다.")
        }
        .foregroundColor(Color(hex: 0xff5a5a))
        .font(.system(size: 14))
        .lineLimit(1)
        .padding(.horizontal)
    }
}

struct LeaveUserView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LeaveUserView(chatResultModel: .MOCK)
        }
        .background(Color.Theme.background)
    }
}
