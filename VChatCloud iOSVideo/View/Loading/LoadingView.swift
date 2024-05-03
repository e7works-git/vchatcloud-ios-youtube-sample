import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image("logo_pc")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                Spacer()
            }
            Spacer()
            Text("E7works & Joytune")
                .foregroundColor(Color(hex: 0x4c0a0a))
                .opacity(0.42)
                .font(.system(size: 12))
                .padding(.bottom, 30)
        }
        .background(Color(hex: 0xc9c9f2))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
