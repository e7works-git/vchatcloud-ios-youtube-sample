import SwiftUI
import VChatCloudSwiftSDK

struct ChatBodyView: View {
    @ObservedObject var myChannel = MyChannel.shared
    
    @Binding var scrollProxy: ScrollViewProxy?
    @Binding var lastViewId: UUID
    
    @State var isAtBottom = false
    
    @ViewBuilder
    func buildFileView(_ chat: ChatResultModel) -> some View {
        if ChannelMimeType.isImageExt(chat.fileModel?.fileExt ?? "") {
            NavigationLink {
                PreviewImageView(model: chat.fileModel!)
            } label: {
                ChatImageView(chatResultModel: chat)
            }
        } else if ChannelMimeType.isVideoExt(chat.fileModel?.fileExt ?? "") {
            ChatVideoView(chatResultModel: chat)
        } else {
            ChatFileView(chatResultModel: chat)
        }
    }
    
    func computePaddingSize(_ chat: ChatResultModel) -> Int {
        chat.isShowProfile || chat.isShowMyProfile ? 20 : 5
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
            }
            ScrollView {
                ScrollViewReader { value in
                    Group {
                        VStack(spacing: 20) {
                            ForEach(Array(myChannel.myChatlog.enumerated()), id: \.element.id) {  index, chatResult in
                                switch chatResult.address {
                                case .join:
                                    JoinUserView(chatResultModel: chatResult)
                                        .id(index)
                                case .leave:
                                    LeaveUserView(chatResultModel: chatResult)
                                        .id(index)
                                case .notifyMessage:
                                    ChatBaseView(chatResultModel: chatResult) {
                                        switch chatResult.mimeType {
                                        case .text:
                                            ChatTextView(chatResultModel: chatResult)
                                        case .emoji:
                                            ChatEmojiView(chatResultModel: chatResult)
                                        case .file:
                                            buildFileView(chatResult)
                                        default:
                                            EmptyView()
                                            Text("is empty...")
                                        }
                                    }
                                    .id(index)
                                case .whisper:
                                    ChatBaseView(chatResultModel: chatResult) {
                                        ChatWhisperView(chatResultModel: chatResult)
                                    }
                                    .id(index)
                                case .notice:
                                    NoticeView(chatResultModel: chatResult)
                                        .id(index)
                                default:
                                    EmptyView()
                                    Text(chatResult.message)
                                    Text(chatResult.address.rawValue)
                                    Text(chatResult.mimeType.rawValue)
                                    Text("is emp?")
                                }
                            }
                            .onAppear(perform: {
                                self.scrollProxy = value
                                value.scrollTo(lastViewId, anchor: .bottom)
                            })
                            .onChange(of: myChannel.chatlog.count, perform: { _ in
                                if isAtBottom {
                                    value.scrollTo(lastViewId, anchor: .bottom)
                                }
                            })
                            Spacer()
                                .frame(height: 0)
                                .id(lastViewId)
                        }
                        .background(GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                let frame = geo.frame(in: .global)
                                // 스크롤 뷰의 가장 아래에 있는지 확인
                                self.isAtBottom = frame.maxY < UIScreen.main.bounds.height + 20
                            }
                            return Color.clear
                        })
                        .onAppear {
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                                if isAtBottom {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        value.scrollTo(lastViewId)
                                    }
                                }
                            }
                        }

                    }
                    .padding([.horizontal, .top], 15)
                }
            }
        }
    }
}

struct ChatBodyView_Previews: PreviewProvider {
    static var previews: some View {
        @State var scrollProxy: ScrollViewProxy? = nil
        @State var lastViewId = UUID()
        
        ChatBodyView(scrollProxy: $scrollProxy, lastViewId: $lastViewId)
            .onAppear {
                MyChannel.shared.myChatlog.append(.MOCK)
                MyChannel.shared.myChatlog.append(.MOCK)
                MyChannel.shared.myChatlog.append(.MOCK)
                MyChannel.shared.myChatlog.append(.whisperMock)
            }
    }
}
