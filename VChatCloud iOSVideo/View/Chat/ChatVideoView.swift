import SwiftUI
import AVKit
import VChatCloudSwiftSDK

struct ChatVideoView: View {
    @StateObject var chatResultModel: ChatResultModel
    @State var isShowAlert = false
    @State var fileExist = false
    
    @State private var downloadedURL: URL?
    var url: URL? {
        guard let model = chatResultModel.fileModel else {
            return nil
        }
        
        if let url = downloadedURL {
            return url
        }
        
        let file = FileManager.default
        let documentPath = file.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoURL = documentPath
            .appendingPathComponent(model.originFileNm ?? model.fileNm, conformingTo: .item)
        return videoURL
    }
    
    var fileSize: String {
        guard let file = chatResultModel.fileModel else {
            return "0"
        }
        
        if let text = file.fileSizeText {
            return text
        }
        
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(file.fileSize))
    }
    
    func download() {
        guard let file = chatResultModel.fileModel else {
            return
        }
        
        Task {
            let url = await VChatCloudAPI.downloadFile(file)
            DispatchQueue.main.async {
                self.downloadedURL = url
                fileExist.toggle()
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            if let file = chatResultModel.fileModel,
               let url = self.url {

                    HStack(spacing: 0) {
                        if !chatResultModel.isMe {
                            Spacer()
                                .frame(width: 10)
                        }
                        if fileExist {
                            NavigationLink {
                                PreviewVideoView(url: url)
                                    .toolbar(.hidden)
                            } label: {
                                ZStack {
                                    VideoPlayer(player: AVPlayer(url: url))
                                        .scaledToFit()
                                        .cornerRadius(5)
                                        .disabled(true)
                                    Rectangle()
                                        .foregroundColor(Color(hex: 0x00000, decAlpha: 0.5))
                                    Image(systemName: "play.circle")
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(width: 45)
                                        .foregroundColor(.white)
                                }
                                
                            }
                        } else {
                            HStack(alignment: .top, spacing: 0) {
                                Image(systemName: "play.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.top, 8)
                                    .padding(.trailing, 10)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(file.originFileNm ?? file.fileNm)
                                        .lineLimit(1)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: 0x333333))
                                    Text("유효기간 : ~ \(file.expire)")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(hex: 0x666666))
                                    Text("용량 : \(fileSize)")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(hex: 0x666666))
                                    Button {
                                        isShowAlert.toggle()
                                    } label: {
                                        Text("재생")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex: 0x2a5da9))
                                    }
                                }
                                Spacer()
                                
                            }
                            .padding(10)
                            .background(.white)
                            .cornerRadius(5)
                        }
                        if chatResultModel.isMe {
                            Spacer()
                                .frame(width: 10)
                        }
                    }
                    .alert("영상을 재생하시겠습니까?", isPresented: $isShowAlert) {
                        Button("취소", role: .cancel) {}
                        Button("다운로드") {
                            download()
                        }
                    } message: {
                        Text("영상을 재생하기 위해 다운로드(\(fileSize)) 합니다.")
                    }
            } else {
                EmptyView()
            }
        }
        .onAppear {
            let file = FileManager.default
            if let url = self.url {
                self.fileExist = file.fileExists(atPath: url.path())
            } else {
                self.fileExist = false
            }
        }
    }
}

struct ChatVideoView_Previews: PreviewProvider {
    static var previews: some View {
        ChatVideoView(chatResultModel: .videoMock)
            .padding()
            .background(Color.Theme.background)
    }
}
