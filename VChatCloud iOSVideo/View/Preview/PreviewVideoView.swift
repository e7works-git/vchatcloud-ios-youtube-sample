import SwiftUI
import AVKit

struct PreviewVideoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var url: URL
    @State var isShowMenu = true
    @State var isLoading = false
    
    @State var player: AVPlayer?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                }
                Spacer()
            }
            .ignoresSafeArea()
            .padding()
            .background(.black)
            let player = AVPlayer(url: self.url)
            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                }
        }
        .background(.black)
        .foregroundColor(.white)
    }
}

struct PreviewVideoView_Previews: PreviewProvider {
    static var url: URL {
        let file = FileManager.default
        let documentPath = file.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoURL = documentPath
            .appendingPathComponent("bee.mp4", conformingTo: .item)

        return videoURL
    }
    
    static var previews: some View {
        PreviewVideoView(url: self.url)
    }
}
