import SwiftUI
import VChatCloudSwiftSDK

struct EmojiFieldView: View {
    @State var currentEmojiIndex = 1
    
    @Binding var lastViewId: UUID
    @Binding var scrollProxy: ScrollViewProxy?
    @ObservedObject var vChatCloud = VChatCloud.shared

    // 이모지 파일 개수
    private let emojiData: [Int: Int] = [
        1: 20,
        2: 18,
        3: 12,
        4: 20,
        5: 18,
        6: 10,
        7: 24,
    ]
    
    func sendEmoji(_ emoji: String) {
        vChatCloud.channel?.sendEmoji(emoji)
        scrollProxy?.scrollTo(lastViewId)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ScrollView(.horizontal) {
                    HStack(spacing: 17) {
                        // 이모티콘 종류 목록
                        ForEach(Array(1..<8), id: \.self) { index in
                            Image("emo0\(index)_ico_\(currentEmojiIndex == index ? "on" : "off")")
                                .resizable()
                                .scaledToFit()
                                .padding(4)
                                .frame(width: 32, height: 32)
                                .background(Color(hex: 0xf2f2f2).opacity(currentEmojiIndex == index ? 1 : 0))
                                .cornerRadius(5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .inset(by: 1)
                                        .stroke(currentEmojiIndex == index ? Color(hex: 0xe3e3e3) : .clear)
                                }
                                .onTapGesture {
                                    currentEmojiIndex = index
                                }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 6)
                }
                Spacer()
            }
            Divider()
            ScrollView {
                ScrollViewReader { proxy in
                    Spacer()
                        .id(0)
                        .frame(height: 15)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 75))], spacing: 15) {
                        // 선택된 이모티콘의 목록
                        if let emojiCount = emojiData[currentEmojiIndex] {
                            ForEach(Array(1..<emojiCount), id: \.self) { index in
                                let emojiUrl = "emo0\(currentEmojiIndex)_\(String(format: "%03d", arguments: [index]))"
                                Image(emojiUrl)
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(1, contentMode: .fit)
                                    .onTapGesture {
                                        // 다른 SDK의 데이터 포맷 통일을 위해 경로 + 이미지 + 확장자까지 전송
                                        sendEmoji("img/emoticon/emo0\(currentEmojiIndex)/\(emojiUrl).png")
                                    }
                            }
                        }
                    }
                    .padding([.horizontal, .bottom], 15)
                    .onChange(of: currentEmojiIndex, perform: { _ in
                        proxy.scrollTo(0)
                    })
                }
            }
        }
        .background(.white)
        .frame(height: 327)
    }
}

struct EmojiFieldView_Previews: PreviewProvider {
    static var previews: some View {
        @State var lastViewId: UUID = UUID()
        @State var scrollProxy: ScrollViewProxy?
        
        EmojiFieldView(lastViewId: $lastViewId, scrollProxy: $scrollProxy)
    }
}
