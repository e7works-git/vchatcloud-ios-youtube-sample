import SwiftUI
import AlertToast
import CachedAsyncImage
import VChatCloudSwiftSDK

struct PreviewImageView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var model: FileItemModel
    @State var isShowMenu = true
    @State var isLoading = false

    func download() {
        if isLoading {
            return
        }

        isLoading = true
        Task {
            _ = await VChatCloudAPI.downloadFile(model)
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            CachedAsyncImage(
                url: VChatCloudAPI.loadFileUrl(model.fileKey),
                urlCache: .imageCache,
                content: { image in
                    MyScrollView(content:image.resizable().scaledToFit())
                }, placeholder: {
                    Color(hex: 0xd4d4d4)
                }
            )
            .onTapGesture {
                isShowMenu.toggle()
            }
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
                .background(Color(hex: 0x000000, decAlpha: 0.5))
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        download()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                .ignoresSafeArea()
                .padding()
                .background(Color(hex: 0x000000, decAlpha: 0.5))
            }
            .opacity(isShowMenu ? 1 : 0)
        }
        .background(Color.black)
        .foregroundColor(.white)
        .toolbar(.hidden)
        .toast(isPresenting: $isLoading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}

struct PreviewImageView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewImageView(model: .mock)
    }
}
