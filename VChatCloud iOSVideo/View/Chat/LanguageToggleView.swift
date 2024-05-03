import SwiftUI
import VChatCloudSwiftSDK

struct CustomToggle: ToggleStyle {
    private let width = 15.0

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            configuration.label
                .font(.system(size: 10))
                .foregroundColor(Color(hex: 0x666666))
                .padding(.trailing, 5)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: width, height: 4)
                    .foregroundColor(configuration.isOn ? Color(hex: 0xc9ddff) : Color(hex: 0xcccccc))
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 10, height: 10)
                    .padding(.leading, configuration.isOn ? 6 : 0)
                    .foregroundColor(configuration.isOn ? Color(hex: 0x2a61be) : Color(hex: 0x999999))
            }
            .onTapGesture {
                withAnimation {
                    configuration.$isOn.wrappedValue.toggle()
                }
            }
        }
    }
}

struct LanguageToggleView: View {
    let langMap = VChatCloudAPI.langMap
    let userModel: UserModel
    
    @StateObject var myChannel = MyChannel.shared
    @State private var isToggled = false
    @State private var isShowAlert = false
    
    var current: Bool {
        myChannel.translateUserClientKeyMap[userModel.clientKey] != nil
    }
    
    func setLanguage(langCode: String?) {
        withAnimation {
            if langCode != nil {
                myChannel.translateUserClientKeyMap[userModel.clientKey] = langCode
                isToggled = true
            } else {
                myChannel.translateUserClientKeyMap.removeValue(forKey: userModel.clientKey)
                isToggled = false
            }
        }
    }
    
    var body: some View {
        let binding = Binding(
            get: {
                self.current
            },
            set: {
                _ = $0
                if !current {
                    isShowAlert.toggle()
                } else {
                    setLanguage(langCode: nil)
                }
            }
        )

        return Toggle("번역", isOn: binding)
            .toggleStyle(CustomToggle())
            .alert("번역 언어 선택", isPresented: $isShowAlert) {
                ForEach(Array(langMap.keys), id: \.self) { lang in
                    Button(langMap[lang]!) {
                        setLanguage(langCode: lang)
                    }
                }
                Button("번역 안함", role: .destructive) {
                    setLanguage(langCode: nil)
                }
                Button("취소", role: .cancel) {}
            }
   }

}

struct LanguageToggleView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageToggleView(userModel: .MOCK)
    }
}
