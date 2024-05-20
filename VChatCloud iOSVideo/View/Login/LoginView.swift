import SwiftUI
import Combine
import VChatCloudSwiftSDK

enum LoginError: Error {
    case nickname
    case termAgree
    case server
}

struct LoginView: View {
    @AppStorage("nickname") var nickname: String = ""
    @AppStorage("profileIndex") var profileIndex: Int = 1
    @AppStorage("termAgree") var termAgree: Bool = false
    @AppStorage("clientKey") var clientKey: String = ""
    @AppStorage("channelKey") var channelKey: String = "Input ChannelKey"
    @State var showTerm: Bool = false
    @State var logining: Bool = false
    @State var isChannelKeyFocused: Bool = false
    @State var isNicknameFocused: Bool = false
    @FocusState var focusState: Bool

    @StateObject var routerViewModel: RouterViewModel = RouterViewModel()
    @StateObject var userViewModel: UserViewModel = UserViewModel.EMPTY
    @StateObject var chatroomViewModel: ChatroomViewModel = ChatroomViewModel.EMPTY
    @StateObject var errorPopupViewModel: ErrorPopupViewModel = ErrorPopupViewModel()
    
    private let nicknameMaxLength = 8
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func limitText(_ upper: Int) {
        if nickname.count > upper {
            nickname = String(nickname.prefix(upper))
        }
    }

    func goLogin() async {
        do {
            if nickname.isEmpty {
                throw LoginError.nickname
            } else if !termAgree {
                throw LoginError.termAgree
            }

            clientKey = clientKey.isEmpty ? randomString(length: 10) : clientKey
            
            userViewModel.nickname = nickname
            userViewModel.clientKey = clientKey
            userViewModel.grade = "user"
            userViewModel.userInfo = ["profile":profileIndex.description]
            
            if let roomData = await VChatCloudAPI.getRoomInfo(roomId: channelKey),
               let likeCount = await VChatCloudAPI.getLike(roomId: channelKey) {
                chatroomViewModel.channelKey = channelKey
                chatroomViewModel.title = roomData.title
                chatroomViewModel.rtcStat = roomData.rtcStat
                chatroomViewModel.roomType = roomData.roomType
                chatroomViewModel.lockType = roomData.lockType
                chatroomViewModel.userEmail = roomData.userEmail
                chatroomViewModel.userMax = roomData.userMax
                chatroomViewModel.like = likeCount.like_cnt
            }
            
            MyChannel.shared.chatroomViewModel = chatroomViewModel
            MyChannel.shared.userViewModel = userViewModel

            let channel = try await VChatCloud.shared.connect(chatroomViewModel: chatroomViewModel, userViewModel: userViewModel)
            channel.delegate = MyChannel.shared
            try await channel.join()
            _ = await channel.getClientList()
            
            routerViewModel.goChatView()
        } catch LoginError.nickname {
            errorPopupViewModel.title = "닉네임을 설정해주세요."
            errorPopupViewModel.isShowAlert.toggle()
        } catch LoginError.termAgree {
            errorPopupViewModel.title = "약관을 동의해주세요."
            errorPopupViewModel.isShowAlert.toggle()
        } catch LoginError.server {
            errorPopupViewModel.title = "네트워크 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            errorPopupViewModel.isShowAlert.toggle()
        } catch {
            if let channelError = error as? ChannelError {
                VChatCloud.shared.disconnect()
                errorPopupViewModel.title = channelError.description
                errorPopupViewModel.isShowAlert.toggle()
            } else {
                debugPrint("error >>>")
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                }
                Spacer()
                ZStack {
                    VStack(spacing: 0) {
                        // Logo
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.bottom, 13)
                            .frame(width: 240)
                        Text("사용하실 프로필 이미지와 이름을 입력하세요")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0x0a0a6b))
                            .padding(.bottom, 40)
                        // Login Form
                        ZStack {
                            VStack(spacing: 0) {
                                Spacer()
                                HStack(spacing: 0) {
                                    TextField("Channel Key를 입력하세요.", text: $channelKey, onEditingChanged: { isChannelKeyFocused = $0 })
                                        .focused($focusState)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: 0xaaaaaa))
                                        .padding(.leading, 5)
                                        .frame(width: 215)
                                    Button(
                                        action: {
                                            channelKey = "Input ChannelKey"
                                        },
                                        label: {
                                            Image(systemName: "arrow.clockwise.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 15)
                                                .foregroundColor(.gray)
                                        })
                                }
                                Rectangle()
                                    .fill(isChannelKeyFocused ? Color.cyan : Color.gray)
                                    .frame(width: 230, height: 2)
                                    .padding(.top, 5)
                                    .padding(.bottom, 10)
                                // Nickname Input
                                TextField("사용자님의 이름을 입력하세요", text: $nickname, onEditingChanged: { isNicknameFocused = $0 })
                                    .focused($focusState)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: 0xaaaaaa))
                                    .padding(.leading, 5)
                                    .frame(width: 230)
                                    .onReceive(Just(nickname)) { _ in limitText(nicknameMaxLength) }
                                Rectangle()
                                    .fill(isNicknameFocused ? Color.cyan : Color.gray)
                                    .frame(width: 230, height: 2)
                                    .padding(.top, 5)
                                // Term Agree Check
                                HStack(spacing: 0) {
                                    Button(action: {
                                        termAgree.toggle()
                                    }) {
                                        HStack(spacing: 0) {
                                            if (termAgree) {
                                                Image(systemName: "checkmark.square.fill")
                                                    .padding(.trailing, 7)
                                                    .foregroundColor(.blue)
                                            } else {
                                                Image(systemName: "square")
                                                    .padding(.trailing, 7)
                                            }
                                            Button {
                                                showTerm.toggle()
                                            } label: {
                                                Text("사용자 이용 약관")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color(hex: 0x2a5da9))
                                            }
                                            .sheet(
                                                isPresented: $showTerm,
                                                content: {
                                                    TermView()
                                                })
                                            Text("에 동의합니다.")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: 0x333333))
                                        }
                                    }
                                    .buttonStyle(NoTapAnimationStyle())
                                    Spacer()
                                }
                                .padding(.horizontal, 25)
                                .padding(.top, 15)
                                // Login Button
                                Button(action: {
                                    Task {
                                        if !logining {
                                            logining = true
                                            await goLogin()
                                            logining = false
                                        }
                                    }
                                }, label: {
                                    Text("로그인")
                                        .padding()
                                        .frame(width: 200, height: 50)
                                })
                                .alert(isPresented: $errorPopupViewModel.isShowAlert, content: {
                                    Alert(title: Text(errorPopupViewModel.title!).font(.caption))
                                })
                                .foregroundColor(Color(hex: 0xffffff))
                                .background(Color(hex: logining ? 0x666666 : 0x0a0a6b))
                                .clipShape(Capsule())
                                .padding(.top, 25)
                                .padding(.bottom, 20)
                            }
                            .frame(width: 280, height: 260)
                            .background(Color(hex: 0xffffff))
                            .cornerRadius(15)
                            ProfileView(index: $profileIndex)
                                .padding(.bottom, 260)
                        }
                    }
                    // Footer
                    VStack {
                        Spacer()
                        Text("E7works & Joytune")
                            .foregroundColor(Color(hex: 0x4c0a0a))
                            .opacity(0.42)
                            .font(.system(size: 12))
                            .padding(.bottom, 30)
                    }
                }
            }
            .background(Color(hex: 0xc9c9f2))
            .navigationDestination(isPresented: $routerViewModel.isChatView, destination: {
                ChattingView(routerViewModel: routerViewModel, chatroomViewModel: chatroomViewModel, userViewModel: userViewModel)
            })
            .onTapGesture {
                focusState = false
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
