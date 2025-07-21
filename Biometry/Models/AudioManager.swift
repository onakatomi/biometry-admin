//
//  AudioManager.swift
//  Biometry
//
//  Created by Nakatomi on 21/7/2025.
//

import AVFoundation

final class AudioManager {
  static let shared = AudioManager()

  private var player: AVPlayer?

  private var session = AVAudioSession.sharedInstance()

  private init() {}

}
