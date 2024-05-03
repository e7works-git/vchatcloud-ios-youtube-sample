import SwiftUI
import AlertToast
import VChatCloudSwiftSDK

struct TextFieldView: View {
    @ObservedObject var routerViewModel: RouterViewModel
    @ObservedObject var chatroomViewModel: ChatroomViewModel
    @ObservedObject var vChatCloud = VChatCloud.shared
    @ObservedObject var myChannel = MyChannel.shared
    
    @Binding var lastViewId: UUID
    @Binding var scrollProxy: ScrollViewProxy?
    @Binding var isShowEmoji: Bool
    @Binding var isShowToast: Bool
    
    @State var input: String = ""
    @State var imageModel: AlbumItemModel?
    @State var videoModel: AlbumItemModel?
    @State var selectedFileURL: URL?
    @State var isShowImagePicker = false
    @State var isShowFilePicker = false
    @State var isShowAlert = false
    @ObservedObject var errorPopupViewModel = ErrorPopupViewModel()

    @FocusState var focusField: String?
    
    var isInputEmpty: Bool {
        input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var timeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: .now)
    }
    
    func editingChange(value: Bool) {
        if !value {
            // 메시지 작성 종료 시 키보드 내림
            focusField = nil
        } else {
            // 메시지 작성 시작 시 이모지 내림
            isShowEmoji = false
        }
    }
    
    func toggleEmoji() {
        focusField = nil
        isShowEmoji.toggle()
    }
    
    func sendMessage() {
        if !isInputEmpty {
            vChatCloud.channel?.sendMessage(input)
            input = ""
            self.scrollProxy?.scrollTo(lastViewId, anchor: .bottom)
        }
    }
    
    func uploadFile(url: URL) {
        isShowToast = true
        Task {
            do {
                _ = try await vChatCloud.channel?.sendFile(url: url)
            } catch {
                DispatchQueue.main.async {
                    print(error)
                    self.errorPopupViewModel.title = "오류"
                    if let vchatcloudError = error as? VChatCloudError {
                        if vchatcloudError == .fileSizeLimit {
                            self.errorPopupViewModel.description = "100MB 이하인 파일만 전송할 수 있습니다."
                        }
                    } else {
                        self.errorPopupViewModel.description = "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해 주시기 바랍니다."
                    }
                    isShowAlert.toggle()
                }
            }
            DispatchQueue.main.async {
                isShowToast = false
            }
        }
    }
    
    func upload(_ albumItemModel: AlbumItemModel?) {
        guard let model = albumItemModel else {
            return
        }

        if model.name.isEmpty || model.data.isEmpty {
            debugPrint("upload fail: model name or data is empty")
            debugPrint("name: \(model.name)")
            debugPrint("data: \(model.data)")
            return
        }
        
        isShowToast = true
        Task {
            do {
                _ = try await vChatCloud.channel?.sendFile(data: model.data, fileName: model.name)
            } catch {
                print(error)

                DispatchQueue.main.async {
                    self.errorPopupViewModel.title = "오류"
                    if let vchatcloudError = error as? VChatCloudError {
                        if vchatcloudError == .fileSizeLimit {
                            self.errorPopupViewModel.description = "100MB 이하인 파일만 전송할 수 있습니다."
                        }
                    } else {
                        self.errorPopupViewModel.description = "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해 주시기 바랍니다."
                    }
                    isShowAlert.toggle()
                }
            }
            DispatchQueue.main.async {
                isShowToast = false
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ZStack {
                    Capsule()
                        .padding([.vertical, .leading], 10)
                        .padding(.trailing, 5)
                        .foregroundColor(.white)
                    HStack(spacing: 0) {
                        Menu {
                            Button("파일", action: {
                                isShowFilePicker.toggle()
                            })
                            Button("사진 및 동영상", action: {
                                isShowImagePicker.toggle()
                            })
                        } label: {
                            Image("ico_fileopen")
                        }
                        .padding(.leading, 18)
                        .disabled(isShowToast)
                        .fileImporter(isPresented: $isShowFilePicker, allowedContentTypes: [.image, .item]) { result in
                            if let url = try? result.get() {
                                uploadFile(url: url)
                            }
                        }
                        .sheet(isPresented: $isShowImagePicker, content: {
                            AlbumPicker(imageModel: $imageModel, videoModel: $videoModel)
                        })
                        .onChange(of: imageModel) { _ in
                            upload(imageModel)
                        }
                        .onChange(of: videoModel) { _ in
                            upload(videoModel)
                        }
                        .alert(errorPopupViewModel.title ?? "오류", isPresented: $isShowAlert) {
                            Button("확인") {}
                        } message: {
                            Text(errorPopupViewModel.description ?? "알 수 없는 오류가 발생했습니다.")
                        }
                        TextField("", text: $input, onEditingChanged: editingChange)
                            .padding(.horizontal, 5)
                            .focused($focusField, equals: "inputt")
                        Image(isShowEmoji ? "ico_emoticon_focus" : "ico_emoticon_default")
                            .onTapGesture {
                                toggleEmoji()
                            }
                            .padding(.trailing, 12)
                    }
                }
                Image("send")
                    .colorMultiply(isInputEmpty ? .gray.opacity(0.5) : .white)
                    .disabled(isInputEmpty)
                    .onTapGesture {
                        sendMessage()
                    }
                    .padding(.trailing, 10)
            }
            .frame(height: 50)
            .background(Color(hex: 0xeeeeee))
            if isShowEmoji {
                EmojiFieldView(lastViewId: $lastViewId, scrollProxy: $scrollProxy)
                    .onAppear {
                        scrollProxy?.scrollTo(lastViewId)
                    }
            }
        }
    }
}

struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        @FocusState var focusField: String?
        @State var lastViewId = UUID()
        @State var scrollProxy: ScrollViewProxy? = nil
        @State var isShowEmoji = false
        @State var isShowToast = false
        
        TextFieldView(routerViewModel: .init(), chatroomViewModel: .MOCK, lastViewId: $lastViewId, scrollProxy: $scrollProxy, isShowEmoji: $isShowEmoji, isShowToast: $isShowToast)
    }
}
