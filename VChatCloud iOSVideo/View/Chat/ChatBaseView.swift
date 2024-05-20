import SwiftUI
import VChatCloudSwiftSDK

struct ChatBaseView<Content>: View where Content: View {
    private enum AlertType {
        case whisper
        case hide
        case block
        case blockDone
        case report
        case reportDone
    }
    
    @StateObject var chatResultModel: ChatResultModel
    @ViewBuilder var content: () -> Content
    
    @State var isShowAlert = false
    @State private var alertType: AlertType = .whisper
    @State var input: String = ""

    let maxWidth = UIScreen.main.bounds.width / 2
    
    var profile: some View {
        Group {
            let profile = chatResultModel.userInfo["profile"] as? String ?? "1"
            Image("profile_img_\(profile)")
                .resizable()
                .scaledToFit()
        }
        .frame(width: 26, height: 26)
        .clipShape(Circle())
        .overlay {
            Circle()
                .inset(by: 2)
                .stroke(Color(hex: 0xeaeaea), lineWidth: 2)
        }
    }
    
    var nickname: String {
        let nickname = chatResultModel.nickname
        if chatResultModel.address != .whisper {
            return nickname
        }
        
        if chatResultModel.isMe {
            return nickname + "님에게"
        } else {
            return nickname + "님이"
        }
    }
    
    var alertTitle: String {
        switch alertType {
        case .whisper:
            return "\(chatResultModel.nickname)님에게 귓속말"
        case .hide:
            return "채팅 내용을 가리시겠습니까?"
        case .block:
            return "해당 유저를 차단하시겠습니까?"
        case .blockDone:
            return "차단 되었습니다."
        case .report:
            return "해당 유저를 신고하시겠습니까?"
        case .reportDone:
            return "신고 처리되었습니다."
        }
    }
    
    func whisper(_ message: String, clientKey: String) {
        guard let channel = VChatCloud.shared.channel else {
            return
        }

        channel.sendWhisper(message, receivedClientKey: clientKey, receivedUserNickname: chatResultModel.nickname)
    }
    
    func hide() {
        chatResultModel.isDeleted = true
    }
    
    func report() {
        guard let channel = VChatCloud.shared.channel else {
            return
        }
        
        Task {
            _ = await VChatCloudAPI.reportUser(roomId: channel.chatroomViewModel.channelKey, banUserClientKey: chatResultModel.clientKey, banUserNickname: chatResultModel.nickname, banMessage: chatResultModel.message)
            DispatchQueue.main.async {
                alertType = .reportDone
                isShowAlert.toggle()
            }
        }
    }

    func block(clientKey: String) {
        MyChannel.shared.blockedUser.append(clientKey)
        DispatchQueue.main.async {
            alertType = .blockDone
            isShowAlert.toggle()
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if chatResultModel.address == .whisper {
                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 0) {
                        // 자식 뷰
                        if chatResultModel.isDeleted {
                            ChatTextView(chatResultModel: chatResultModel)
                        } else {
                            content()
                        }
                    }
                    Text(chatResultModel.messageDt.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xbbbbbb))
                }
            } else {
                profile
                VStack(alignment: .leading, spacing: 5) {
                    Text(self.nickname)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x666666))
                    HStack(spacing: 0) {
                        // 자식 뷰
                        if chatResultModel.isDeleted {
                            ChatTextView(chatResultModel: chatResultModel)
                        } else {
                            content()
                        }
                        VStack {
                            HStack {
                                Spacer()
                            }
                        }
                    }
                    Text(chatResultModel.messageDt.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xbbbbbb))
                }
            }
        }
        .contentShape(Rectangle())
        .contextMenu(menuItems: {
            if chatResultModel.mimeType == .text {
                Button("복사") {
                    UIPasteboard.general.string = chatResultModel.message
                }
            }
            if !chatResultModel.isMe {
                Button("\(chatResultModel.nickname)님에게 귓속말") {
                    alertType = .whisper
                    isShowAlert.toggle()
                }
                Button("가리기") {
                    alertType = .hide
                    isShowAlert.toggle()
                }
                Button("차단하기") {
                    alertType = .block
                    isShowAlert.toggle()
                }
                Button("신고하기") {
                    alertType = .report
                    isShowAlert.toggle()
                }
            }
        })
        .alert(alertTitle, isPresented: $isShowAlert) {
            switch alertType {
            case .whisper:
                TextField("내용을 입력하세요.", text: $input)
                Button("취소", role: .cancel) {}
                Button("전송") {
                    whisper(input, clientKey: chatResultModel.clientKey)
                    input = ""
                }
            case .hide:
                Button("취소", role: .cancel) {}
                Button("가리기") {
                    hide()
                }
            case .block:
                Button("취소", role: .cancel) {}
                Button("차단하기") {
                    block(clientKey: chatResultModel.clientKey)
                }
            case .blockDone:
                Button("확인", role: .cancel) {}
            case .report:
                Button("취소", role: .cancel) {}
                Button("신고하기") {
                    report()
                }
            case .reportDone:
                Button("확인", role: .cancel) {}
            }
        } message: {
            switch alertType {
            case .whisper:
                Text("")
            case .hide:
                Text("해당 내용은 현재 기기에서만 가려집니다.")
            case .block:
                Text("차단하면 재접속까지 해당 사용자의 채팅이 보이지 않게 됩니다.")
            case .blockDone:
                Text("")
            case .report:
                Text("신고 후 검토까지는 최대 24시간이 소요됩니다.\nVChatCloud 운영정책에 따라 강퇴될 수 있음을 알립니다.")
            case .reportDone:
                Text("")
            }
        }
    }
}

struct ChatBaseView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ChatBaseView(chatResultModel: ChatResultModel.MOCK) {
                ChatTextView(chatResultModel: ChatResultModel.MOCK)
            }
            ChatBaseView(chatResultModel: ChatResultModel.MOCK) {
                ChatTextView(chatResultModel: ChatResultModel.MOCK)
            }
            ChatBaseView(chatResultModel: ChatResultModel.MOCK) {
                ChatTextView(chatResultModel: ChatResultModel.MOCK)
            }
            ChatBaseView(chatResultModel: ChatResultModel.whisperMock) {
                ChatWhisperView(chatResultModel: ChatResultModel.whisperMock)
            }
            ChatBaseView(chatResultModel: ChatResultModel.EMPTY) {
                ChatTextView(chatResultModel: ChatResultModel.EMPTY)
            }
        }
        .padding()
        .background(Color.Theme.background)
    }
}
