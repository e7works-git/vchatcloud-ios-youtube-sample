import SwiftUI
import VChatCloudSwiftSDK

struct TitleBarView: View {
    @ObservedObject var routerViewModel: RouterViewModel
    @ObservedObject var chatroomViewModel: ChatroomViewModel
    @ObservedObject var vChatCloud = VChatCloud.shared
    @ObservedObject var myChannel = MyChannel.shared

    @State var isUserListDrawerOpen: Bool = false
    @State var isFileDrawerOpen: Bool = false
    @State var isHelpDrawerOpen: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            Image("exit_left")
                .onTapGesture {
                    routerViewModel.goLogin()
                    VChatCloud.shared.disconnect()
                }
            HStack() {
                VStack(alignment: .leading, spacing: 0) {
                    Text(chatroomViewModel.title)
                        .foregroundColor(Color(hex: 0x666666))
                        .lineLimit(1)
                        .font(.system(size: 17))
                        .padding(.bottom, 2)
                    HStack(spacing: 0) {
                        Group {
                            Image("ico_userlist")
                                .padding(.trailing, 3)
                            Text(String(chatroomViewModel.personString))
                                .font(.caption)
                                .foregroundColor(Color(hex: 0x999999))
                                .font(.system(size: 12))
                                .padding(.trailing, 12)
                        }
                        .sheet(isPresented: $isUserListDrawerOpen, content: {
                            UserListView(isUserListDrawerOpen: $isUserListDrawerOpen)
                        })
                        .onTapGesture {
                            Task {
                                _ = await vChatCloud.channel?.getClientList()
                            }
                            isUserListDrawerOpen.toggle()
                        }
                        Group {
                            Image("ico_like")
                                .padding(.trailing, 3)
                            Text(String(chatroomViewModel.likeString))
                                .font(.caption)
                                .foregroundColor(Color(hex: 0x999999))
                                .font(.system(size: 12))
                        }
                        .onTapGesture {
                            Task {
                                let result = await VChatCloudAPI.like(roomId: chatroomViewModel.channelKey)
                                if let count = result?.like_cnt {
                                    chatroomViewModel.like = count
                                }
                            }
                        }
                    }
                }
                Spacer()

                Image("ico_allviewfile")
                    .sheet(isPresented: $isFileDrawerOpen, content: {
                        FileDrawerView(isFileDrawerOpen: $isFileDrawerOpen, chatroomViewModel: chatroomViewModel)
                    })
                    .onTapGesture {
                        isFileDrawerOpen.toggle()
                    }

                Image("ico_help")
                    .sheet(isPresented: $isHelpDrawerOpen, content: {
                        HelpDrawerView(isHelpDrawerOpen: $isHelpDrawerOpen)
                    })
                    .onTapGesture {
                        isHelpDrawerOpen.toggle()
                    }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(height: 50)
    }
}

struct TitleBarView_Previews: PreviewProvider {
    static var previews: some View {
        TitleBarView(
            routerViewModel: RouterViewModel(),
            chatroomViewModel: ChatroomViewModel.MOCK
        )
        .background(.orange)
    }
}

