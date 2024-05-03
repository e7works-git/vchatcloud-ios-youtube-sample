import Foundation

class RouterViewModel: ObservableObject {
    @Published var isLoginView: Bool = false
    @Published var isChatView: Bool = false
    
    func goLogin() {
        isChatView = false
        isLoginView = true
    }
    
    func goChatView() {
        isLoginView = false
        isChatView = true
    }
}
