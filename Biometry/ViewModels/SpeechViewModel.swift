//
//  SpeechViewModel.swift
//  Biometry
//
//  Created by Nakatomi on 22/7/2025.
//

import Foundation

@MainActor
final class SpeechViewModel: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String?
    
    private let service = AudioTranscriptionService()
    
    func requestPermissions() async {
        do { try await service.requestAuthorization() }
        catch { errorMessage = "Speech permission denied." }
    }
    
    func startRecording() {
        do {
            transcript = ""
            isRecording = true
            try service.start(partialHandler: { [weak self] partial in
                Task { @MainActor in self?.transcript = partial }
            }, finalHandler: { [weak self] final in
                Task { @MainActor in
                    self?.transcript = final
                    self?.isRecording = false
                }
            }, errorHandler: { [weak self] error in
                Task { @MainActor in
                    self?.errorMessage = error.localizedDescription
                    self?.isRecording = false
                }
            })
        } catch {
            errorMessage = error.localizedDescription
            isRecording = false
        }
    }
    
    func stopRecording() {
        service.stop()
        isRecording = false
    }
    
    func reset() {
        service.reset()
        transcript = ""
        isRecording = false
        errorMessage = nil
    }
}

