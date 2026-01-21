//
//  ContentView.swift
//  VoiceCommandApp
//
//  Created by Noman belim on 21/01/26.
//
import SwiftUI
import Speech
import AVFoundation

// MARK: - Content View
struct ContentView: View {
    @StateObject private var voiceController = VoiceCommandController()
    
    var body: some View {
        ZStack {
            // Dark Futuristic Background
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
            
            // Background Glow
            Circle()
                .fill(Color.blue.opacity(0.15))
                .blur(radius: 100)
                .offset(y: -200)

            VStack(spacing: 30) {
                Text("Voice Commander")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [.white, .blue], startPoint: .top, endPoint: .bottom))
                
                Spacer()

                // Visualizer Section
                ZStack {
                    // Animated Rings (Pulse based on volume)
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            .frame(width: 120 + CGFloat(i * 40), height: 120 + CGFloat(i * 40))
                            .scaleEffect(voiceController.isListening ? 1 + (voiceController.audioLevel * 1.5) : 1)
                            .animation(.easeOut(duration: 0.1), value: voiceController.audioLevel)
                    }

                    // Microphone Button
                    Button(action: { voiceController.toggleListening() }) {
                        ZStack {
                            Circle()
                                .fill(voiceController.isListening ? Color.red.gradient : Color.blue.gradient)
                                .frame(width: 100, height: 100)
                                .shadow(color: voiceController.isListening ? .red.opacity(0.5) : .blue.opacity(0.5), radius: 20)
                            
                            Image(systemName: voiceController.isListening ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Transcription Bubble
                VStack(spacing: 15) {
                    Text(voiceController.isListening ? "I'm listening..." : "Ready for command")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.blue.opacity(0.8))
                        .textCase(.uppercase)

                    if !voiceController.recognizedText.isEmpty {
                        Text("\"\(voiceController.recognizedText)\"")
                            .font(.title3)
                            .italic()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.05)))
                    }
                }
                .frame(height: 120)

                // Feedback Message
                if !voiceController.statusMessage.isEmpty {
                    Label(voiceController.statusMessage, systemImage: voiceController.hasError ? "exclamationmark.triangle" : "checkmark.circle")
                        .font(.subheadline)
                        .foregroundColor(voiceController.hasError ? .red : .green)
                        .padding()
                        .background(Capsule().fill(Color.black.opacity(0.3)))
                }

                Spacer()

                // Command Suggestions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        SuggestionChip(text: "What time is it?")
                        SuggestionChip(text: "Open Youtube")
                        SuggestionChip(text: "Search for Mars")
                        SuggestionChip(text: "Add 15 plus 30")
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .onAppear {
            voiceController.requestPermissions()
        }
    }
}

struct SuggestionChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().stroke(Color.white.opacity(0.2)))
            .foregroundColor(.white.opacity(0.7))
    }
}

