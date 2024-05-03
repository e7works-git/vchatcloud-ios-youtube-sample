import SwiftUI
import AlertToast
import VChatCloudSwiftSDK

struct ChatFileView: View {
    @StateObject var chatResultModel: ChatResultModel
    @State var loading = false
    
    var fileName: String {
        chatResultModel.fileModel?.originFileNm ?? chatResultModel.fileModel?.fileNm ?? "this is file.pdf"
    }
    
    var fileSizeText: String {
        if let size = chatResultModel.fileModel?.fileSizeText {
            return size
        } else {
            let formatter = ByteCountFormatter()
            return formatter.string(fromByteCount: Int64(chatResultModel.fileModel?.fileSize ?? 0))
        }
    }
    
    func download() {
        guard let fileModel = chatResultModel.fileModel else {
            debugPrint("file model is not valid")
            return
        }
        
        loading = true
        Task {
            _ = await VChatCloudAPI.downloadFile(fileModel)
            DispatchQueue.main.async {
                loading = false
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if !chatResultModel.isMe {
                Spacer()
                    .frame(width: 10)
            }
            HStack(alignment: .top, spacing: 0) {
                Image(systemName: "doc")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(.top, 8)
                    .padding(.trailing, 10)
                VStack(alignment: .leading, spacing: 5) {
                    Text(fileName)
                        .lineLimit(1)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x333333))
                    Text("유효기간 : ~ \(chatResultModel.fileModel?.expire ?? "")")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0x666666))
                    Text("용량 : \(fileSizeText)")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0x666666))
                    Button {
                        download()
                    } label: {
                        Text("저장")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: 0x2a5da9))
                    }
                    .disabled(loading)
                }
                Spacer()
            }
            .padding(10)
            .background(.white)
            .cornerRadius(5)
            if chatResultModel.isMe {
                Spacer()
                    .frame(width: 10)
            }
        }
        .toast(isPresenting: $loading) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}

struct ChatFileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ChatBaseView(chatResultModel: .MOCK) {
                ChatFileView(chatResultModel: .MOCK)
            }
            Spacer()
        }
        .background(Color.Theme.background)
    }
}
