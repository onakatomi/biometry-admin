import SwiftUI

struct PrimaryButton: View {
    let text: String
    let disabled: Bool
    let color: Color
    let handler: (() -> Void)
    
    init(
      text: String,
      disabled: Bool = false,
      color: Color = .blue,
      handler: @escaping ()->Void
    ) {
      self.text = text
      self.disabled = disabled
      self.color = color
      self.handler = handler
    }
    
    var body: some View {
        Button(text) {
            handler()
        }
           .buttonStyle(.borderedProminent)
           .tint(color)
           .disabled(disabled)
      }
}

#Preview {
    PrimaryButton(text: "Choose files") {
        print("Choosing files...")
    }
}
