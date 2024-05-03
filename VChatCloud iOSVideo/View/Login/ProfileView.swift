import SwiftUI

struct ProfileView: View {
    let MIN_INDEX = 1
    let MAX_INDEX = 48
    @Binding var index: Int
    
    func prev() {
        index -= 1
        if index < MIN_INDEX {
            index = MAX_INDEX
        }
    }
    
    func next() {
        index += 1
        if index > MAX_INDEX {
            index = MIN_INDEX
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: prev, label: {
                Image("arr_left")
            })
            .padding(.trailing, 10)
            Image("profile_img_\(index)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .cornerRadius(100)
                .overlay(
                    Circle()
                        .stroke(Color(hex: 0xeaeaea), lineWidth: 5)
                )
            Button(action: next, label: {
                Image("arr_right")
            })
            .padding(.leading, 10)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        @State var index: Int = 1
        ProfileView(index: $index)
    }
}
