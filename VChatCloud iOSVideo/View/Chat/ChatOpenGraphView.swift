import SwiftUI
import CachedAsyncImage
import VChatCloudSwiftSDK

struct ChatOpenGraphView: View {
    @StateObject var chatResultModel: ChatResultModel
    @State var openGraphModel: OpenGraphResponseModel?

    var firstUrl: String? {
        let reg = /[a-zA-Z0-9@:%_\+.~#?&\/\/=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)?/
        if let match = chatResultModel.message.firstMatch(of: reg) {
            // 일치하는 부분을 String으로 변환하여 반환
            return String(match.output.0)
        } else {
            return nil
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            if let urlString = firstUrl,
               let url = URL(string: urlString) {
                Link(destination: url) {
                    VStack(alignment: .leading, spacing: 0) {
                        if let open = openGraphModel {
                            if let imageUrl = URL(string: open.data.image) {
                                CachedAsyncImage(
                                    url: imageUrl,
                                    urlCache: .imageCache,
                                    content: { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxHeight: 100)
                                        .clipped()
                                    }, placeholder: {
                                        Color.gray
                                            .frame(minHeight: 100)
                                    }
                                )
                            }
                            VStack(alignment: .leading, spacing: 0) {
                                Text(open.data.title)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: 0x333333))
                                    .lineLimit(1)
                                Spacer().frame(height: 5)
                                Text(open.data.description)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: 0x666666))
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                HStack {
                                    Spacer()
                                }
                            }
                            .padding(10)
                        }
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.top, openGraphModel != nil ? 5 : 0)
                    .onAppear {
                        Task {
                            if firstUrl != nil && openGraphModel == nil {
                                if let open = await VChatCloudAPI.openGraph(requestUrl: urlString) {
                                    DispatchQueue.main.async {
                                        openGraphModel = open
                                    }
                                }
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
            } else {
                EmptyView()
            }
        }
    }
}

struct ChatOpenGraphView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            Rectangle()
            ChatOpenGraphView(chatResultModel: .openGraphMock)
            Rectangle()
        }
        .padding()
        .background(Color.Theme.background)
    }
}
