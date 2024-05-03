import SwiftUI
import AlertToast
import CachedAsyncImage
import VChatCloudSwiftSDK

struct FileDrawerView: View {
    private enum Tab {
        case image
        case video
        case file
    }

    private enum AlertType {
        case loading
        case done
    }
    
    @Binding var isFileDrawerOpen: Bool
    @ObservedObject var chatroomViewModel: ChatroomViewModel
    
    @State private var selectedTab: Tab = .image
    @State var images: [FileItemModel] = []
    @State var videos: [FileItemModel] = []
    @State var files: [FileItemModel] = []
    @State var selectedFile: Set<FileItemModel> = Set([])
    @State private var alertType: AlertType = .loading
    @State var showToast = false
    
    var targetFiles: [FileItemModel] {
        switch selectedTab {
        case .image:
            return images
        case .video:
            return videos
        case .file:
            return files
        }
    }
    
    func toggleSelect(_ fileItemModel: FileItemModel) {
        if selectedFile.contains(fileItemModel) {
            selectedFile.remove(fileItemModel)
        } else {
            selectedFile.insert(fileItemModel)
        }
    }
    
    private func tabButtonView(_ tab: Tab, title: String) -> some View {
        Button(action: {
            selectedTab = tab
        }, label: {
            VStack(spacing: 0) {
                Text(title)
                    .padding(.bottom, 6)
                Rectangle()
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .foregroundColor(Color(hex: 0x333333, decAlpha:  selectedTab == tab ? 1 : 0))
            }
        })
        .buttonStyle(NoTapAnimationStyle())
    }
    
    func imageView(_ fileItemModel: FileItemModel, selected: Bool) -> some View {
        NavigationLink(destination: PreviewImageView(model: fileItemModel)) {
            CachedAsyncImage(
                url: VChatCloudAPI.loadFileUrl(fileItemModel.fileKey),
                urlCache: .imageCache,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background(Color(hex: 0xd4d4d4))
                }, placeholder: {
                    Color(hex: 0xd4d4d4)
                }
            )
        }
    }
    
    func videoView(_ fileItemModel: FileItemModel, selected: Bool) -> some View {
        HStack(spacing: 0) {
            Image(systemName: "play.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 3) {
                Text(fileItemModel.originFileNm ?? fileItemModel.fileNm)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x333333))
                Text(fileItemModel.expire)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0x666666))
                Text(fileItemModel.fileSizeText ?? fileItemModel.fileSize.description)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0x666666))
            }
            Spacer()
        }
        .padding(10)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: selected ? 0x2a61be : 0xdddddd), lineWidth: selected ? 2 : 1)
        )
        .opacity(selected ? 1 : 0.7)
    }
    
    func fileView(_ fileItemModel: FileItemModel, selected: Bool) -> some View {
        HStack(spacing: 0) {
            Image(systemName: "doc")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 3) {
                Text(fileItemModel.originFileNm ?? fileItemModel.fileNm)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x333333))
                Text(fileItemModel.expire)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0x666666))
                Text(fileItemModel.fileSizeText ?? fileItemModel.fileSize.description)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: 0x666666))
            }
            Spacer()
        }
        .padding(10)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: selected ? 0x2a61be : 0xdddddd), lineWidth: selected ? 2 : 1)
        )
        .opacity(selected ? 1 : 0.7)
    }
    
    func downloadSelectedFiles() {
        let count = selectedFile.count
        var current = 0
        alertType = .loading
        showToast = true
        selectedFile.forEach { model in
            Task {
                _ = await VChatCloudAPI.downloadFile(model)
                current += 1
                if current == count {
                    alertType = .done
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showToast = false
                    }
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("파일 모아보기")
                    .foregroundColor(Color(hex: 0x333333))
                    .bold()
                Spacer()
                Image(systemName: "xmark")
                    .onTapGesture {
                        isFileDrawerOpen.toggle()
                    }
            }
            .padding(15)
            HStack(alignment: .bottom, spacing: 0) {
                tabButtonView(.image, title: "사진")
                tabButtonView(.video,title: "동영상")
                tabButtonView(.file, title: "파일")
            }
            .onChange(of: selectedTab, perform: { _ in
                selectedFile.removeAll()
            })
            Divider()
                .padding(.bottom, 15)
            GeometryReader { geometry in
                ScrollView {
                    Group {
                        if self.targetFiles.isEmpty {
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                }
                                Text("업로드 된 파일이 없습니다.").multilineTextAlignment(.center)
                            }
                        } else {
                            switch selectedTab {
                            case .image:
                                LazyVGrid(columns: Array(1...3).map({ _ in GridItem(.flexible()) }), spacing: 10) {
                                    ForEach(targetFiles) { value in
                                        let size = (geometry.size.width - 80) / 3
                                        imageView(value, selected: selectedFile.contains(value))
                                            .frame(width: size, height: size)
                                            .clipped()
                                            .cornerRadius(5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(Color(hex: 0x2a61be), lineWidth: (selectedFile.contains(value)) ? 2 : 0)
                                            )
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                toggleSelect(value)
                                            }
                                    }
                                }
                                .padding(1)
                            case .video, .file:
                                VStack(spacing: 10) {
                                    ForEach(targetFiles) { value in
                                        Group {
                                            switch selectedTab {
                                            case .image:
                                                EmptyView()
                                            case .video:
                                                videoView(value, selected: selectedFile.contains(value))
                                            case .file:
                                                fileView(value, selected: selectedFile.contains(value))
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            toggleSelect(value)
                                        }
                                    }
                                }
                                .padding(1)
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
            }
            Divider()
            HStack(spacing: 0) {
                Group {
                    Image(systemName: selectedFile.isEmpty ? "circle" : "checkmark.circle.fill")
                        .padding(.trailing, 5)
                        .foregroundColor(Color(hex: selectedFile.isEmpty ? 0x666666 : 0x2A61BE))
                    Text("\(selectedFile.count)개 선택")
                        .foregroundColor(Color(hex: 0x666666))
                }
                .onTapGesture {
                    selectedFile.removeAll()
                }
                Spacer()
                Button {
                    downloadSelectedFiles()
                } label: {
                    Text("저장")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: 0x333333))
                }
            }
            .padding(15)
        }
        .toast(isPresenting: $showToast, alert: {
            switch alertType {
            case .loading:
                return AlertToast(displayMode: .alert, type: .loading)
            case .done:
                return AlertToast(displayMode: .alert, type: .complete(.green), title: "저장되었습니다.")
            }
        })
        .onAppear(perform: {
            Task {
                let result = await VChatCloudAPI.getFileList(roomId: chatroomViewModel.channelKey)
                if let fileList = result?.data?.list {
                    // UI변경은 메인스레드에서 실행되어야 함
                    await MainActor.run {
                        self.images = fileList.filter { ["png", "jpg", "jpeg", "bmp"].contains($0.fileExt?.lowercased() ?? "") }
                        self.videos = fileList.filter { ["mp4", "wmv", "avi", "mkv"].contains($0.fileExt?.lowercased() ?? "") }
                        self.files = fileList.filter { !["png", "jpg", "jpeg", "bmp", "mp4", "wmv", "avi", "mkv"].contains($0.fileExt?.lowercased() ?? "") }
                    }
                }
            }
        })
    }
}

struct FileDrawerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isOpen = true
        FileDrawerView(isFileDrawerOpen: $isOpen, chatroomViewModel: .MOCK)
    }
}
