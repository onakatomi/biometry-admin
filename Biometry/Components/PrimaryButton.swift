import SwiftUI

struct PrimaryButton: View {
    let text: String
    let handler: (() -> Void)
    
    var body: some View {
        Button(text) {
            handler()
        }
           .buttonStyle(.borderedProminent)
      }
}

#Preview {
    PrimaryButton(text: "Choose files") {
        print("Choosing files...")
    }
}
