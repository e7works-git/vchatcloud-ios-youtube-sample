import SwiftUI
import PhotosUI
import FileProviderUI
import AlertToast
import VChatCloudSwiftSDK
import YouTubePlayerKit

struct ChattingView: View {
    @ObservedObject var routerViewModel: RouterViewModel
    @ObservedObject var chatroomViewModel: ChatroomViewModel
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var vChatCloud = VChatCloud.shared
    @ObservedObject var myChannel = MyChannel.shared

    @State var isShowEmoji: Bool = false
    @State var isShowToast: Bool = false
    @State var scrollProxy: ScrollViewProxy? = nil
    @State var lastViewId = UUID()
    @State var keyboardHeight = 0.0

    @StateObject
    var youTubePlayer: YouTubePlayer = YouTubePlayer(source: .url("https://www.youtube.com/watch?v=3A81Xx6l-YI"), configuration: .init(autoPlay: true, loopEnabled: true))
    @FocusState var focusField: String?
    
    func hideAll() {
        focusField = nil
        isShowEmoji = false
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .ignoresSafeArea()
                        .background(.green)
                    YouTubePlayerView(self.youTubePlayer) { state in
                        // Overlay ViewBuilder closure to place an overlay View
                        // for the current `YouTubePlayer.State`
                        switch state {
                        case .idle:
                            ProgressView()
                        case .ready:
                            EmptyView()
                        case .error(_):
                            Text(verbatim: "YouTube player couldn't be loaded")
                        }
                    }
                }
                .frame(maxHeight: 250)
                Divider()
                TitleBarView(routerViewModel: routerViewModel, chatroomViewModel: chatroomViewModel)
                    .onTapGesture {
                        hideAll()
                    }
                Divider()
                ChatBodyView(scrollProxy: $scrollProxy, lastViewId: $lastViewId)
                    .onTapGesture {
                        hideAll()
                    }
                TextFieldView(routerViewModel: routerViewModel, chatroomViewModel: chatroomViewModel, lastViewId: $lastViewId, scrollProxy: $scrollProxy, isShowEmoji: $isShowEmoji, isShowToast: $isShowToast, focusField: _focusField)
            }
            .toolbar(.hidden)
            .onAppear {
                self.keyboardHeight = 0
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { noti in
                    let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    let height = value.height
                    self.keyboardHeight = height
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    self.keyboardHeight = 0
                }
            }
        }
        .toast(isPresenting: $isShowToast) {
            AlertToast(type: .loading)
        }
    }
}

struct ChattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChattingView(routerViewModel: RouterViewModel(), chatroomViewModel: .MOCK, userViewModel: UserViewModel.MOCK)
            .onAppear {
                MyChannel.shared.chatlog.append(.mock)
                MyChannel.shared.myChatlog.append(.MOCK)
            }
    }
}
