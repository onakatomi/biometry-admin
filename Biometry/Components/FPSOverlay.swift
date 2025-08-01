//
// This entire file was generated by ChatGPT and so I'm not fully across the logic and how it's doing what it's doing, as achieving FPS display appears to be non-trivial. But it works.
//

import Cocoa
import AVKit
import CoreVideo
import Combine

// An overlay that shows the *actual* playback framerate,
// measuring rendered frames via AVPlayerItemVideoOutput + CVDisplayLink.
final class FPSOverlay: NSTextField {
    
    private weak var player: AVPlayer?
    private let videoOutput: AVPlayerItemVideoOutput
    private var displayLink: CVDisplayLink?
    private var frameCount = 0
    private var lastTimestamp = CFAbsoluteTimeGetCurrent()
    
    init(attachedTo player: AVPlayer) {
        self.player = player
        
        // 1) Set up pixel‐buffer output
        let attrs: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String:
                Int(kCVPixelFormatType_32BGRA)
        ]
        self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: attrs)
        super.init(frame: .zero)
        
        // style your label
        isBezeled = false
        drawsBackground = false
        isEditable = false
        textColor = .systemGreen
        font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        stringValue = "-- fps"
        
        // attach the output when item is ready
        if let item = player.currentItem {
            item.add(videoOutput)
        } else {
            // observe when playerItem becomes non‐nil
            player.publisher(for: \.currentItem)
                  .compactMap { $0 }
                  .first()
                  .sink { [weak self] item in
                      item.add(self!.videoOutput)
                  }
                  .store(in: &cancellables)
        }
        
        // 2) Create a display‐link
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let dl = link else { return }
        displayLink = dl
        
        // callback for each refresh
        CVDisplayLinkSetOutputCallback(dl, { (
            _,
            _,
            _,
            _,
            _,
            userInfo
        ) -> CVReturn in
            let overlay = Unmanaged<FPSOverlay>
                .fromOpaque(userInfo!)
                .takeUnretainedValue()
            overlay.countFrameIfNeeded()
            return kCVReturnSuccess
        }, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        // start it
        CVDisplayLinkStart(dl)
    }
    
    required init?(coder: NSCoder) { nil }
    
    deinit {
        if let dl = displayLink {
            CVDisplayLinkStop(dl)
        }
    }
    
    private func countFrameIfNeeded() {
        guard let player = player,
              let currentItem = player.currentItem else { return }
        
        // host time for next vsync
        let hostTime = CACurrentMediaTime()
        var itemTime = videoOutput.itemTime(forHostTime: hostTime)
        
        // if a new frame is available, consume it & count
        if videoOutput.hasNewPixelBuffer(forItemTime: itemTime) {
            _ = videoOutput.copyPixelBuffer(forItemTime: itemTime,
                                            itemTimeForDisplay: nil)
            frameCount += 1
        }
        
        // every 1.0s, update the label on main thread
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastTimestamp >= 1.0 {
            let fps = Double(frameCount) / (now - lastTimestamp)
            DispatchQueue.main.async {
                self.stringValue = String(format: "%.0f fps", fps)
            }
            frameCount = 0
            lastTimestamp = now
        }
    }
    
    // for Combine observation of player.currentItem
    private var cancellables = Set<AnyCancellable>()
}
