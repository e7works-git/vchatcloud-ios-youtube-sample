import SwiftUI

struct ContentView: View {
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            LoadingView()
                .onAppear {
                    // 1초 후에 로그인 화면으로 전환
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                       isLoading = false
                    }
                }
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
