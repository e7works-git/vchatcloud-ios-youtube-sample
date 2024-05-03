import SwiftUI

struct ChatTextView: View {
    @StateObject var chatResultModel: ChatResultModel
    
    var color: Color {
        if chatResultModel.address == .whisper {
            return Color(hex: 0xffeb3b)
        } else if chatResultModel.isMe {
            return Color(hex: 0xb2c7eb)
        } else {
            return .white
        }
    }
    
    var message: String {
        chatResultModel.isDeleted ? "가려진 메시지입니다." : chatResultModel.message
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
            }
            Text(message)
                .foregroundColor(chatResultModel.isDeleted ? .gray : Color(hex: 0x333333))
            if !chatResultModel.isDeleted {
                ChatOpenGraphView(chatResultModel: chatResultModel)
            }
        }
    }
}

struct ChatTextView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 0) {
                ChatBaseView(chatResultModel: .MOCK) {
                    ChatTextView(chatResultModel: ChatResultModel.MOCK)
                }
                ChatBaseView(chatResultModel: .openGraphMock) {
                    ChatTextView(chatResultModel: .openGraphMock)
                }
                ChatBaseView(chatResultModel: .EMPTY) {
                    ChatTextView(chatResultModel: .EMPTY)
                }
            }
            .padding()
            .background(Color.Theme.background)
        }
    }
}
