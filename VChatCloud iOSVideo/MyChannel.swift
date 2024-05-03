import Foundation
import VChatCloudSwiftSDK

class MyChannel: ChannelDelegate, ObservableObject {
    static var shared: MyChannel = MyChannel()
    public var chatroomViewModel: ChatroomViewModel?
    public var userViewModel: UserViewModel?

    private init() {}
    
    @Published var clients: [UserModel] = []
    @Published var chatlog: [ChannelResultModel] = []
    @Published var myChatlog: [ChatResultModel] = []
    @Published var translateUserClientKeyMap: [String: String] = [:]
    
    private func addMyChatlog(_ channelResultModel: ChannelResultModel) {
        var temp = channelResultModel
        switch temp.address {
        // 유저 특정 정보가 필요하지 않은 타입의 클라이언트 키 제거 (메시지 레이아웃 유지를 위해)
        case .notice, .join, .leave:
            temp.body["clientKey"] = ""
        default:
            break
        }
        
        myChatlog.last?.nextDt = temp.messageDt
        myChatlog.last?.nextClientKey = temp.body["clientKey"] as? String
        
        if let userModel = userViewModel?.userModel,
           let chatResult = temp.computedChatResult(userModel: userModel, prevChannelResultModel: chatlog.last, nextChannelResultModel: nil) {
            chatlog.append(temp)
            myChatlog.append(chatResult)

            if let langCode = translateUserClientKeyMap[temp.body["clientKey"] as! String],
               let channelKey = chatroomViewModel?.channelKey {
                if chatResult.mimeType != .text {
                    return
                }
                
                Task {
                    let response = await VChatCloudAPI.googleTranslation(text: chatResult.message, targetLanguageCode: langCode, roomId: channelKey)
                    DispatchQueue.main.async {
                        if let text = response?.data {
                            chatResult.message = text
                            chatResult.isTranslated = true
                        }
                    }
                }
            }
        }
    }
    
    private func addHistoryMyChatlog(_ channelResultModel: ChannelResultModel) {
        var temp = channelResultModel
        switch temp.address {
        // 유저 특정 정보가 필요하지 않은 타입의 클라이언트 키 제거 (메시지 레이아웃 유지를 위해)
        case .notice, .join, .leave:
            temp.body["clientKey"] = ""
        default:
            break
        }
        
        myChatlog.first?.previousDt = temp.messageDt
        myChatlog.first?.previousClientKey = temp.body["clientKey"] as? String

        if let userModel = userViewModel?.userModel,
           let chatResult = temp.computedChatResult(userModel: userModel, prevChannelResultModel: nil, nextChannelResultModel: chatlog.first) {
            chatlog.insert(temp, at: 0)
            myChatlog.insert(chatResult, at: 0)
        }
    }
    
    func onJoinUserInit(_ channelResultModel: ChannelResultModel) {
        if let history = channelResultModel.body["history"] as? Array<[String: Any]> {
            history
                .map({ ChannelResultModel(dictionary: ["type": "rec", "address": ChannelResultAddress.notifyMessage.rawValue, "body": $0]) })
                .forEach({ channelHistory in
                    guard let model = channelHistory else {
                        return
                    }
                    addHistoryMyChatlog(model)
                })
        }
    }
    
    func onClientList(_ channelResultModel: ChannelResultModel) {
        if let clientList = channelResultModel.body["clientlist"] as? Array<[String: Any]> {
            let userModels: [UserModel?] = clientList.map({ body in
                if let nickname = body["nickName"] as? String,
                   let clientKey = body["clientKey"] as? String,
                   let grade = body["grade"] as? String {
                    return UserModel(nickname: nickname, clientKey: clientKey, grade: grade, userInfo: body["userInfo"] as? [String: Any] ?? [:])
                } else {
                    return nil
                }
            })
            var filterdList: [UserModel] = []
            DispatchQueue.main.async {
                userModels.forEach { userModel in
                    // 중복 및 nil 제거
                    if let model = userModel {
                        if !filterdList.contains(where: { arrayInUserModel in
                            arrayInUserModel.clientKey == model.clientKey
                        }) {
                            filterdList.append(model)
                        }
                    }
                }
                self.clients = filterdList
                self.chatroomViewModel?.persons = self.clients.count
            }
        }
    }
    
    func onMessage(_ channelResultModel: ChannelResultModel) {
        addMyChatlog(channelResultModel)
    }
    
    func onWhisper(_ channelResultModel: ChannelResultModel) {
        addMyChatlog(channelResultModel)
    }
    
    func onNotice(_ channelResultModel: ChannelResultModel) {
        addMyChatlog(channelResultModel)
    }
    
    func onCustom(_ channelResultModel: ChannelResultModel) {
        addMyChatlog(channelResultModel)
    }
    
    func onJoinUser(_ channelResultModel: ChannelResultModel) {
        addMyChatlog(channelResultModel)
    }
    
    func onLeaveUser(_ channelResultModel: ChannelResultModel) {
        addMyChatlog(channelResultModel)
    }
    
    func onPersonalKickUser(_ channelResultModel: ChannelResultModel) {
        addNotice(message: "강제퇴장 당하셨습니다.")
    }
    
    func onPersonalMuteUser(_ channelResultModel: ChannelResultModel) {
        addNotice(message: "채팅 금지되었습니다.")
    }
    
    func onPersonalUnmuteUser(_ channelResultModel: ChannelResultModel) {
        addNotice(message: "채팅 금지가 해제되었습니다.")
    }
    
    func onPersonalDuplicateUser(_ channelResultModel: ChannelResultModel) {
        addNotice(message: "다른 곳에서 로그인되었습니다.")
    }
    
    func onPersonalInvite(_ channelResultModel: ChannelResultModel) {
        if let roomId = channelResultModel.body["roomId"] as? String {
            debugPrint("\(roomId)방에 초대되었습니다.")
            debugPrint("채팅 데모에서 지원되지 않는 기능입니다.")
        }
    }
    
    func onKickUser(_ channelResultModel: ChannelResultModel) {
        if let nickname = channelResultModel.body["nickName"] as? String {
            addNotice(message: "\(nickname)님이 강제퇴장 당하셨습니다.")
        }
    }
    
    func onUnkickUser(_ channelResultModel: ChannelResultModel) {
        if let nickname = channelResultModel.body["nickName"] as? String {
            addNotice(message: "\(nickname)님의 강제퇴장이 해제되었습니다.")
        }
    }
    
    func onMuteUser(_ channelResultModel: ChannelResultModel) {
        if let nickname = channelResultModel.body["nickName"] as? String,
           let clientKey = channelResultModel.body["clientKey"] as? String {
            // onPersonalMuteUser와 중복 알림 방지
            if clientKey != self.userViewModel?.clientKey {
                addNotice(message: "\(nickname)님이 채팅 금지되었습니다.")
            }
        }
    }
    
    func onUnmuteUser(_ channelResultModel: ChannelResultModel) {
        if let nickname = channelResultModel.body["nickName"] as? String,
           let clientKey = channelResultModel.body["clientKey"] as? String {
            // onPersonalUnmuteUser와 중복 알림 방지
            if clientKey != self.userViewModel?.clientKey {
                addNotice(message: "\(nickname)님의 채팅 금지가 해제되었습니다.")
            }
        }
    }
    
    func onSendWhisper(_ channelResultModel: ChannelResultModel) {
        addMyChatlog(channelResultModel)
    }
    
    func onDisconnect(reason: String, errorCode: UInt16) {
        addNotice(message: "서버와의 연결이 끊어졌습니다.")
    }
    
    func disconnect() {
        chatroomViewModel = nil
        userViewModel = nil
        clients.removeAll()
        chatlog.removeAll()
        myChatlog.removeAll()
    }
    
    private func addNotice(message: String) {
        let body = [
            "nickname": "System",
            "clientKey": "",
            "message": message,
            "mimeType": ChannelMimeType.text.rawValue,
            "messageDt": Date.now,
            "userInfo": "{}",
        ] as [String: Any]
        let model = ChannelResultModel(type: "rec", address: .notice, body: body)
        addMyChatlog(model)
    }
}
