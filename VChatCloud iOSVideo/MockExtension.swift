import Foundation
import VChatCloudSwiftSDK

extension UserModel {
    static var EMPTY: UserModel {
        UserModel(nickname: "", clientKey: "", grade: "", userInfo: [:])
    }
    static var MOCK: UserModel {
        UserModel(nickname: "Lorem ipsum", clientKey: "asdfasdf", grade: "user", userInfo: ["profile":"1"])
    }
}

extension ChannelResultModel {
    static var mock: ChannelResultModel {
        ChannelResultModel(dictionary: ["type": "rec", "address": ChannelResultAddress.notifyMessage, "body": ["message": "asdadsas"]])!
    }
}

extension ChatResultModel {
    static var EMPTY: ChatResultModel {
        return ChatResultModel(address: .notifyMessage, nickname: "", clientKey: "", message: "", mimeType: .text, messageDt: Date.now)
    }
    static var MOCK: ChatResultModel {
        return ChatResultModel(address: .notifyMessage, nickname: "asdasd", clientKey: "asdasd", message: "Lorem ipsum dolor sit amet consectetur adipisicing elit.", mimeType: .text, messageDt: Date.now, userInfo: ["profile": "1"], isMe: true)
    }
    static var openGraphMock: ChatResultModel {
        let mock = ChatResultModel.MOCK
        mock.message = "Lorem ipsum dolor sit amet consectetur adipisicing elit. https://vchatcloud.com"
        return mock
    }
    static var videoMock: ChatResultModel {
        let mock = ChatResultModel.MOCK
        mock.fileModel = FileItemModel(fileNm: "lorem.mp4", fileSize: 500, expire: "20240101", fileKey: "CHANGE_FILE_KEY")
        return mock
    }
    static var whisperMock: ChatResultModel {
        let mock = ChatResultModel.MOCK
        mock.address = .whisper
        return mock
    }
}

extension ChatroomModel {
    static var EMPTY: ChatroomModel {
        return ChatroomModel(
            channelKey: "",
            title: "",
            persons: 0,
            like: 0,
            rtcStat: "",
            roomType: "",
            lockType: "",
            userEmail: "",
            userMax: 0
        )
    }
    static var MOCK: ChatroomModel {
        return ChatroomModel(
            channelKey: "CHANNEL_KEY",
            title: "Lorem ipsum dolor sit amet consectetur adipisicing elit.",
            persons: 12,
            like: 39,
            rtcStat: "N",
            roomType: "01",
            lockType: "",
            userEmail: "email@vchatcloud.com",
            userMax: 10
        )
    }
}

extension ChatroomViewModel {
    static var EMPTY: ChatroomViewModel {
        ChatroomViewModel(from: ChatroomModel.EMPTY)
    }
    static var MOCK: ChatroomViewModel {
        ChatroomViewModel(from: ChatroomModel.MOCK)
    }
}

extension UserViewModel {
    static var EMPTY: UserViewModel {
        UserViewModel(from: UserModel.EMPTY)
    }
    static var MOCK: UserViewModel {
        UserViewModel(from: UserModel.MOCK)
    }
}

extension FileItemModel {
    static var mock: FileItemModel {
        FileItemModel(fileNm: "", fileSize: 500, expire: "", fileKey: "FILE_KEY")
    }
}
