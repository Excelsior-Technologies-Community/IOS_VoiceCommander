//
//  VoiceCommandManager.swift
//  VoiceCommandApp
//
//  Created by Noman belim on 21/01/26.
//
import Foundation
import SwiftUI
import Speech
import AVFoundation


// MARK: - Controller
final class VoiceCommandController: ObservableObject {
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var statusMessage = ""
    @Published var hasError = false
    @Published var audioLevel: CGFloat = 0.0

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?
    private let speaker = AVSpeechSynthesizer()

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { _ in }
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }

    func toggleListening() {
        isListening ? stopListening() : try? startListening()
    }

    private func startListening() throws {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            showError("Speech recognition unavailable")
            return
        }

        stopListening()
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try session.setActive(true)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        recognitionRequest?.shouldReportPartialResults = true

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.recognitionRequest?.append(buffer)
            
            // Calculate Volume Level for Visualizer
            let channelData = buffer.floatChannelData?[0]
            let frames = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
            let rms = sqrt(frames.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
            DispatchQueue.main.async {
                self.audioLevel = CGFloat(rms)
            }
        }

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                
                self.silenceTimer?.invalidate()
                self.silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                    self.processCommand(self.recognizedText)
                    self.stopListening()
                }
            }

            if error != nil { self.stopListening() }
        }

        audioEngine.prepare()
        try audioEngine.start()
        isListening = true
        statusMessage = "Listening..."
    }

    private func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isListening = false
        audioLevel = 0
    }

    private func processCommand(_ text: String) {
        let command = text.lowercased()
        if command.isEmpty { return }

        // 1. Math
        if handleMath(command) { return }
        
        // 2. System Intelligence (Time/Date/Battery)
        if handleSystem(command) { return }
        
        // 3. Web & App Opening
        if handleOpening(command) { return }
        
        // 4. Default to Search if no clear intent found
        handleSearch(command)
    }

    private func handleMath(_ command: String) -> Bool {
        let numbers = command.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
        guard numbers.count >= 2 else { return false }
        let (a, b) = (numbers[0], numbers[1])
        
        var res: Int?
        if command.contains("plus") || command.contains("add") { res = a + b }
        else if command.contains("minus") || command.contains("subtract") { res = a - b }
        else if command.contains("multiply") || command.contains("times") { res = a * b }
        
        if let val = res {
            provideResponse("The answer is \(val)")
            return true
        }
        return false
    }

    private func handleSystem(_ command: String) -> Bool {
        if command.contains("time") {
            let time = Date().formatted(date: .omitted, time: .shortened)
            provideResponse("It is currently \(time)")
            return true
        }
        if command.contains("date") || command.contains("today") {
            let date = Date().formatted(date: .long, time: .omitted)
            provideResponse("Today is \(date)")
            return true
        }
        if command.contains("battery") {
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = Int(UIDevice.current.batteryLevel * 100)
            provideResponse("Your battery is at \(level) percent")
            return true
        }
        return false
    }

    private func handleOpening(_ command: String) -> Bool {
        guard command.contains("open") else { return false }
        let target = command.replacingOccurrences(of: "open ", with: "").trimmingCharacters(in: .whitespaces)
        
        let schemes = ["whatsapp": "whatsapp://", "youtube": "youtube://", "spotify": "spotify://", "instagram": "instagram://"]
        
        for (key, scheme) in schemes where target.contains(key) {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                provideResponse("Opening \(key)")
                return true
            }
        }
        
        // Fallback: Open as Website
        let urlString = target.contains(".") ? "https://\(target)" : "https://www.\(target).com"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
            provideResponse("Navigating to \(target)")
            return true
        }
        return false
    }

    private func handleSearch(_ command: String) {
        let query = command.replacingOccurrences(of: "search for ", with: "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.google.com/search?q=\(query)") {
            UIApplication.shared.open(url)
            provideResponse("Searching Google for \(command)")
        }
    }

    private func provideResponse(_ text: String) {
        statusMessage = text
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.52
        utterance.pitchMultiplier = 1.1 // Slightly higher pitch for a "cleaner" AI sound
        speaker.speak(utterance)
    }

    private func showError(_ message: String) {
        statusMessage = message
        hasError = true
    }
}
