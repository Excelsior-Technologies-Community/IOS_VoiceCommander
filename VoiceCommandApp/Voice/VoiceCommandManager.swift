//
//  VoiceCommandManager.swift
//  VoiceCommandApp
//
//  Created by Noman belim on 21/01/26.
//
import Foundation
import Speech
import AVFoundation
import UIKit
import SwiftUI

final class VoiceCommandController: ObservableObject {

    // MARK: - UI State
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var statusMessage = ""
    @Published var hasError = false
    @Published var audioLevel: CGFloat = 0.0

    // MARK: - Audio & Speech
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?
    private let speaker = AVSpeechSynthesizer()

    // MARK: - Permissions
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { _ in }
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }

    // MARK: - Toggle Listening
    func toggleListening() {
        isListening ? stopListening() : startListeningSafely()
    }

    // MARK: - Safe Starter
    private func startListeningSafely() {
        do {
            try startListening()
        } catch {
            showError("Failed to start listening")
        }
    }

    // MARK: - Start Listening (FINAL VERSION)
    private func startListening() throws {

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            showError("Speech recognition unavailable")
            return
        }

        // Always stop before restarting
        stopListening()

        // 🔥 AUDIO SESSION — MUST BE HERE
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [.defaultToSpeaker, .allowBluetooth]
        )
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode

        // 🔥 IMPORTANT FIX — format: nil
        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: nil
        ) { [weak self] buffer, _ in
            guard let self = self else { return }

            self.recognitionRequest?.append(buffer)

            // Audio level (RMS)
            if let channelData = buffer.floatChannelData?[0] {
                let frameLength = Int(buffer.frameLength)
                let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
                let rms = sqrt(samples.map { $0 * $0 }.reduce(0, +) / Float(frameLength))

                DispatchQueue.main.async {
                    self.audioLevel = CGFloat(rms)
                }
            }
        }

        recognitionTask = recognizer.recognitionTask(
            with: recognitionRequest!
        ) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let text = result.bestTranscription.formattedString

                DispatchQueue.main.async {
                    self.recognizedText = text
                }

                // 🔁 Auto-stop on silence
                self.silenceTimer?.invalidate()
                self.silenceTimer = Timer.scheduledTimer(
                    withTimeInterval: 1.5,
                    repeats: false
                ) { _ in
                    DispatchQueue.main.async {
                        self.processCommand(self.recognizedText)
                        self.stopListening()
                    }
                }

                if result.isFinal {
                    self.silenceTimer?.invalidate()
                    DispatchQueue.main.async {
                        self.processCommand(self.recognizedText)
                        self.stopListening()
                    }
                }
            }

            if error != nil {
                self.stopListening()
            }
        }

        audioEngine.prepare()
        try audioEngine.start()

        DispatchQueue.main.async {
            self.isListening = true
            self.statusMessage = "Listening…"
            self.hasError = false
        }
    }

    // MARK: - Stop Listening
    private func stopListening() {
        silenceTimer?.invalidate()
        silenceTimer = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        DispatchQueue.main.async {
            self.isListening = false
            self.audioLevel = 0
        }
    }

    // MARK: - Command Router
    private func processCommand(_ text: String) {
        let command = text.lowercased()
        if command.isEmpty { return }

        if handleMath(command) { return }
        if handleSystem(command) { return }
        if handleOpening(command) { return }

        handleSearch(command)
    }

    // MARK: - Math
    private func handleMath(_ command: String) -> Bool {
        let numbers = command
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }

        guard numbers.count >= 2 else { return false }
        let a = numbers[0]
        let b = numbers[1]

        var result: Int?
        if command.contains("add") || command.contains("plus") {
            result = a + b
        } else if command.contains("subtract") || command.contains("minus") {
            result = a - b
        } else if command.contains("multiply") || command.contains("times") {
            result = a * b
        } else if command.contains("divide"), b != 0 {
            result = a / b
        }

        if let value = result {
            respond("The answer is \(value)")
            return true
        }
        return false
    }

    // MARK: - System
    private func handleSystem(_ command: String) -> Bool {
        if command.contains("time") {
            respond("It is \(Date().formatted(date: .omitted, time: .shortened))")
            return true
        }
        if command.contains("date") || command.contains("today") {
            respond("Today is \(Date().formatted(date: .long, time: .omitted))")
            return true
        }
        return false
    }

    // MARK: - Open App / Website
    private func handleOpening(_ command: String) -> Bool {
        guard command.contains("open") else { return false }

        let target = command.replacingOccurrences(of: "open", with: "").trimmingCharacters(in: .whitespaces)

        let apps: [String: String] = [
            "whatsapp": "whatsapp://",
            "youtube": "youtube://",
            "spotify": "spotify://",
            "instagram": "instagram://",
            "chat gpt": "https://chat.openai.com"
        ]

        for (key, scheme) in apps where target.contains(key) {
            if let url = URL(string: scheme) {
                UIApplication.shared.open(url)
                respond("Opening \(key)")
                return true
            }
        }

        let urlString = target.contains(".")
            ? "https://\(target)"
            : "https://www.\(target).com"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
            respond("Opening \(target)")
            return true
        }

        return false
    }

    // MARK: - Search
    private func handleSearch(_ command: String) {
        let query = command.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://www.google.com/search?q=\(query)") {
            UIApplication.shared.open(url)
            respond("Searching for \(command)")
        }
    }

    // MARK: - Voice Response
    private func respond(_ text: String) {
        statusMessage = text
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.52
        speaker.speak(utterance)
    }

    // MARK: - Error
    private func showError(_ message: String) {
        statusMessage = message
        hasError = true
    }
}
