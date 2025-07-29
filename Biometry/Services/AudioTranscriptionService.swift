//
//  AudioTranscriptionService.swift
//  Biometry
//
//  Created by Nakatomi on 22/7/2025.
//

import SwiftUI
import Speech
import AVFoundation

final class AudioTranscriptionService: NSObject {
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognizer: SFSpeechRecognizer?
    private var task: SFSpeechRecognitionTask?
    
    enum ServiceError: Error { case permissionDenied, recognizerUnavailable, audioFailure }
    
    func requestAuthorization() async throws {
        try await withCheckedThrowingContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                switch status {
                case .authorized: cont.resume()
                default: cont.resume(throwing: ServiceError.permissionDenied)
                }
            }
        }
    }
    
    func start(locale: Locale = Locale(identifier: "en-US"),
               partialHandler: @escaping (String) -> Void,
               finalHandler: @escaping (String) -> Void,
               errorHandler: @escaping (Error) -> Void) throws {
        
        guard SFSpeechRecognizer(locale: locale)?.isAvailable == true else {
            throw ServiceError.recognizerUnavailable
        }
        recognizer = SFSpeechRecognizer(locale: locale)
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        task = recognizer?.recognitionTask(with: request!) { result, error in
            if let error = error { errorHandler(error); return }
            guard let result = result else { return }
            
            if result.isFinal {
                finalHandler(result.bestTranscription.formattedString)
            } else {
                partialHandler(result.bestTranscription.formattedString)
            }
        }
    }
    
    func stop() {
        task?.finish()
        task?.cancel()
        task = nil
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        
        request?.endAudio()
        request = nil
    }
    
    func reset() {
        stop()
    }
}
