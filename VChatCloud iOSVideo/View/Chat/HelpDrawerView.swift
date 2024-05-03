import SwiftUI

struct HelpDrawerView: View {
    @Binding var isHelpDrawerOpen: Bool
    
    func title(_ title: String) -> some View {
        Text(title)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .font(.system(size: 14))
            .foregroundColor(Color(hex: 0xfefefe))
            .background(Color(hex: 0x0a0a6b))
            .clipShape(Capsule())
    }
    
    func text(_ text: String) -> Text {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(Color(hex: 0x333333))
    }

    var body: some View {
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("도움말")
                    .foregroundColor(Color(hex: 0x333333))
                    .bold()
                Spacer()
                Image(systemName: "xmark")
                    .onTapGesture {
                        isHelpDrawerOpen.toggle()
                    }
            }
            .padding()
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Group {
                        title("메시지 보내기")
                        Image("help_input")
                            .resizable()
                            .scaledToFit()
                        text("전송하실 메시지를 입력하고 ")
                         +
                        Text(Image(systemName: "paperplane.circle.fill"))
                         +
                        text(" 을 클릭하세요")
                    }
                    
                    Group {
                        title("이모티콘 보내기")
                        Image("help_emoticon")
                            .resizable()
                            .scaledToFit()
                        text("채팅 입력창 우측 ")
                        +
                        Text(Image("ico_emoticon_default"))
                        +
                        text(" 을 클릭하시면 나타나는 목록에서 원하시는 이모티콘을 선택하세요.")
                    }

                    Group {
                        title("귓속말 보내기")
                        Image("help_whisper")
                            .resizable()
                            .scaledToFit()
                        text("원하시는 상대의 대화명을 길게 누르면 나타나는 팝업창에 보내실 귓속말을 작성하고 전송을 클릭하세요.")
                    }
                    
                    Group {
                        title("채팅 언어 번역하기")
                        Image("help_lang_trans")
                            .resizable()
                            .scaledToFit()
                        text("클릭 후 참여자 목록에서 번역할 사용자의 번역 버튼을 클릭하고 팝업창에서 번역할 언어를 선택하세요.")
                    }
                    
                    Group {
                        title("문의하기")
                        (
                            text("문의하실 내용은 ")
                            +
                            Text("support@vchatcloud.com")
                            +
                            text(" 으로 문의해주시기 바랍니다.")
                        )
                            .onTapGesture {
                                UIPasteboard.general.string = "support@vchatcloud.com"
                            }
                    }
                }
                .padding([.horizontal, .bottom], 15)
            }
        }
    }
}

struct HelpDrawerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isHelpDrawerOpen = true
        HelpDrawerView(isHelpDrawerOpen: $isHelpDrawerOpen)
    }
}
