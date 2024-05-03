import PhotosUI
import SwiftUI
import MobileCoreServices
import UIKit

struct AlbumItemModel: Equatable {
    var name: String
    var data: Data
}

struct AlbumPicker: UIViewControllerRepresentable {
    @Binding var imageModel: AlbumItemModel?
    @Binding var videoModel: AlbumItemModel?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        // 초기 팝업 화면 시작 시 기존 데이터 삭제 (미 삭제시 같은 파일 선택하면 onChange가 트리거되지 않음)
        imageModel = nil
        videoModel = nil

        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: AlbumPicker

        init(_ parent: AlbumPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { item, _ in
                        DispatchQueue.main.async {
                            if let name = url?.lastPathComponent,
                               let data = item {
                                self.parent.imageModel = AlbumItemModel(name: name, data: data)
                            }
                        }
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
//                provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { item, _ in
//                    DispatchQueue.main.async {
//                        if let url = item as? URL,
//                           let localURL = copyVideoToAppDirectory(from: url) {
//                            self.parent.videoURL = localURL
//                        }
//                    }
//                }
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.movie.identifier) { item, _ in
                        DispatchQueue.main.async {
                            if let name = url?.lastPathComponent,
                               let data = item {
                                self.parent.videoModel = AlbumItemModel(name: name, data: data)
                            }
                        }
                    }
                }
            }
        }
    }
}
