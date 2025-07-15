import SwiftUI
import AppKit
import CoreGraphics
import Combine

class DisplayModel: ObservableObject {
    @Published var screens: [NSScreen] = []
    @Published var cgDisplayIDs: [CGDirectDisplayID] = []

    private var cancellable: AnyCancellable?

    init() {
        reload()
        cancellable = NotificationCenter.default
            .publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in self?.reload() }
    }

    private func reload() {
        screens = NSScreen.screens
        cgDisplayIDs = fetchActiveDisplays()
    }

    private func fetchActiveDisplays() -> [CGDirectDisplayID] {
        let maxDisplays: UInt32 = 16
        var count: UInt32 = 0
        var ids = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        if CGGetActiveDisplayList(maxDisplays, &ids, &count) == .success {
            return Array(ids.prefix(Int(count)))
        } else {
            return []
        }
    }
}
