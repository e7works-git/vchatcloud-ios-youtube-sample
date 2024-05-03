import Foundation
import VChatCloudSwiftSDK

class ChatResultModel: ObservableObject, Identifiable {
    var id = UUID()
    var address: ChannelResultAddress
    var nickname: String
    var clientKey: String
    var message: String
    var mimeType: ChannelMimeType
    var messageDt: Date
    var userInfo: [String: Any]
    
    var fileModel: FileItemModel?

    @Published var isMe: Bool
    @Published var isDeleted: Bool
    @Published var isTranslated: Bool
    @Published var previousClientKey: String?
    @Published var nextClientKey: String?
    @Published var previousDt: Date?
    @Published var nextDt: Date?
    
    var isPrevSameMinute: Bool {
        guard let previousDt = self.previousDt else {
            return false
        }

        let cal = Calendar.current
        return cal.isDate(previousDt, equalTo: messageDt, toGranularity: .minute)
    }
    
    var isNextSameMinute: Bool {
        guard let nextDt = self.nextDt else {
            return false
        }
        
        let cal = Calendar.current
        return cal.isDate(nextDt, equalTo: messageDt, toGranularity: .minute)
    }
    
    /// 사람 프로필 표시 여부
    /// - 내 채팅이 아닐 때
    ///     - 이전 채팅이 내꺼가 아닐 때
    ///     - 이전 채팅과 같은 시간(분 단위)일 떄
    /// - 내 채팅이 아닐 때 + 귓속말일 때
    var isShowProfile: Bool {
        !isMe && ((previousClientKey != clientKey) || !isPrevSameMinute) ||
        !isMe && address == .whisper
    }
    
    /// 내 프로필 표시 여부
    /// - 내 채팅일 때
    ///     - 이전 채팅이 내꺼가 아닐 때
    ///     - 이전 채팅과 같은 시간(분 단위)일 떄
    /// - 내 채팅일 때 + 귓속말일 때
    var isShowMyProfile: Bool {
        isMe && ((previousClientKey != clientKey) || !isPrevSameMinute) ||
        isMe && address == .whisper
    }
    
    /// 시간 표시 여부
    /// - 다음 채팅과 다른 사람일 때
    /// - 시간(분 단위)이 다를 때
    var isShowTime: Bool {
        (nextClientKey != clientKey) ||
        (!isNextSameMinute)
    }

    init(address: ChannelResultAddress, nickname: String, clientKey: String, message: String, mimeType: ChannelMimeType, messageDt: Date, userInfo: [String : Any] = [:], isMe: Bool = false, isDeleted: Bool = false, isTranslated: Bool = false) {
        self.address = address
        self.nickname = nickname
        self.clientKey = clientKey
        self.message = message
        self.mimeType = mimeType
        self.messageDt = messageDt
        self.userInfo = userInfo
        self.isMe = isMe
        self.isDeleted = isDeleted
        self.isTranslated = isTranslated
    }
}

extension ChannelResultModel {
    func computedChatResult(userModel: UserModel, prevChannelResultModel: ChannelResultModel? = nil, nextChannelResultModel: ChannelResultModel? = nil) -> ChatResultModel? {
        let result = ChatResultModel(
            address: self.address,
            nickname: self.body["nickName"] as? String ?? "",
            clientKey: self.body["clientKey"] as? String ?? "",
            message: self.body["message"] as? String ?? "",
            mimeType: ChannelMimeType(rawValue: self.body["mimeType"] as? String ?? "") ?? .text,
            messageDt: self.messageDt,
            userInfo: self.body["userInfo"] as? [String: Any] ?? [:]
        )
        if let text = self.body["message"] as? String,
           let file = text.jsonToDict as? [[String: Any]] {
            result.fileModel = FileItemModel(
                fileNm: file.first?["name"] as? String ?? "",
                fileSize: file.first?["size"] as? Int ?? 0,
                expire: file.first?["expire"] as? String ?? "",
                fileKey: file.first?["id"] as? String ?? "",
                fileExt: file.first?["type"] as? String ?? "",
                originFileNm: file.first?["name"] as? String ?? ""
            )
        }

        result.isMe = result.clientKey == userModel.clientKey && !result.clientKey.isEmpty
        
        if let prev = prevChannelResultModel {
            result.previousDt = prev.messageDt
            if let prevClientKey = prev.body["clientKey"] as? String {
                result.previousClientKey = prevClientKey
            }
        }
        if let next = nextChannelResultModel {
            result.nextDt = next.messageDt
            if let nextClientKey = next.body["clientKey"] as? String {
                result.nextClientKey = nextClientKey
            }
        }
        
        return result
    }
}
