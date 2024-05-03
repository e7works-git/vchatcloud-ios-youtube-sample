import CachedAsyncImage
import SwiftUI
import VChatCloudSwiftSDK

struct ChatImageView: View {
    @StateObject var chatResultModel: ChatResultModel
    @State var isShowPreview = false
    
    var body: some View {
        HStack {
            if !chatResultModel.isMe {
                Spacer()
                    .frame(width: 10)
            }
            CachedAsyncImage(
                url: VChatCloudAPI.loadFileUrl(chatResultModel.fileModel!.fileKey),
                urlCache: .imageCache,
                content: { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }, placeholder: {
                    Color.gray
                        .frame(minHeight: 200)
                        .cornerRadius(5)
                }
            )
            if chatResultModel.isMe {
                Spacer()
                    .frame(width: 10)
            }
        }
    }
}

struct ChatImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ChatBaseView(chatResultModel: .MOCK) {
                ChatImageView(chatResultModel: .MOCK)
            }
        }
        .background(Color.Theme.background)
    }
}
