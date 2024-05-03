import SwiftUI
import VChatCloudSwiftSDK

struct UserListView: View {
    let langMap = VChatCloudAPI.langMap
    @ObservedObject var myChannel = MyChannel.shared
    
    @Binding var isUserListDrawerOpen: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("채팅 참여자 목록")
                    .foregroundColor(Color(hex: 0x333333))
                    .bold()
                Spacer()
                Image(systemName: "xmark")
                    .onTapGesture {
                        isUserListDrawerOpen.toggle()
                    }
            }
            .padding()
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(myChannel.clients, content: { userModel in
                        HStack(spacing: 8) {
                            let profileIndex = userModel.userInfo["profile"] as? String ?? "1"
                            Image("profile_img_\(profileIndex)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .cornerRadius(35)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: 0xeaeaea), lineWidth: 2)
                                )
                            VStack(alignment: .leading, spacing: 0) {
                                Text(userModel.nickname)
                                    .font(.system(size: 14))
                                      .foregroundColor(Color(hex: 0x333333))
                                HStack(spacing: 5) {
                                    LanguageToggleView(userModel: userModel)
                                    Text(langMap[myChannel.translateUserClientKeyMap[userModel.clientKey] ?? ""] ?? "번역 안함")
                                        .font(.system(size: 10))
                                        .foregroundColor(.black)
                                }
                            }
                            Spacer()
                        }
                        .frame(height: 35)
                        .padding([.horizontal, .bottom], 15)
                    })
                }
            }
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isUserListDrawerOpen = true
        UserListView(isUserListDrawerOpen: $isUserListDrawerOpen)
    }
}
