import SwiftUI

struct PrimaryButton: View {
    let text: String
    let disabled: Bool
    let color: Color
    let handler: () async throws -> Void
    
    @State private var isLoading = false
    @State private var taskError: Error?
    
    init(
        text: String,
        disabled: Bool = false,
        color: Color = .blue,
        handler: @escaping () async throws -> Void
    ) {
        self.text = text
        self.disabled = disabled
        self.color = color
        self.handler = handler
    }
    
    var body: some View {
        Button {
            isLoading = true
            taskError = nil
            
            Task {
                defer { isLoading = false }
                do {
                    try await handler()
                } catch {
                    taskError = error
                    // handle or rethrow as you like
                    print("Button handler failed:", error)
                }
            }
        } label: {
            ZStack {
                // keep the label size steady by layering
                Text(text)
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }
            }
            .padding(3)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
        .disabled(disabled || isLoading)
    }
}

#Preview {
    PrimaryButton(text: "Choose files") {
        print("Choosing files...")
    }
}
