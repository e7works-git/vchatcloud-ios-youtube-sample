import Foundation

class ErrorPopupViewModel: ObservableObject {
    @Published var error: Error?
    @Published var title: String?
    @Published var description: String?
    @Published var isShowAlert: Bool = false
    
    init(error: Error? = nil, title: String? = nil, description: String? = nil) {
        self.error = error
        self.title = title
        self.description = description
    }
}
