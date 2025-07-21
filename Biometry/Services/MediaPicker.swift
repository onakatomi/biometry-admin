//
//  VideoPicker.swift
//  Biometry
//
//  Created by Nakatomi on 17/7/2025.
//

import AppKit
import UniformTypeIdentifiers

// Open the native file picker to select videos/audio to playback
struct MediaPicker {
    static func pickVideos(completion: @escaping ([URL]) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .video]
        panel.allowsMultipleSelection = true
        panel.begin { response in
            guard response == .OK else { return }
            completion(panel.urls)
        }
    }
    
    static func pickAudioFile(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = false
        panel.begin { response in
            guard response == .OK else {
                completion(nil)
                return
            }
            completion(panel.urls.first)
        }
    }
}
