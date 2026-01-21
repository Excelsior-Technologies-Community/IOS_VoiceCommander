# 🎙️ VoiceCommander – SwiftUI Voice Assistant App

<div align="center">
  
  ![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
  ![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
  ![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)
  ![License](https://img.shields.io/badge/License-MIT-yellow.svg)
  
  **A Siri-like voice assistant built with SwiftUI that understands natural language commands**
  
  [Features](#-features) • [Demo](#-demo) • [Installation](#-installation) • [Usage](#-usage) • [Documentation](#-documentation)

</div>

---

## 🎤 Example Voice Commands

Try saying these natural phrases:

```
🌐 "Open YouTube"
🧮 "Add 10 plus 2"
💱 "Convert 10,000 INR to US Dollar"
🔢 "Divide 100 by 5"
✖️ "Multiply 3 with 3"
📱 "Open WhatsApp"
🔍 "What is capital of India"
⏰ "What time is it"
🤖 "Open ChatGPT"
🌍 "Open Google"
```

> **Note:** The app understands natural language, not just fixed phrases!

---

## ✨ Features

<table>
  <tr>
    <td>
      <h3>🎯 Smart Recognition</h3>
      <ul>
        <li>Real-time speech-to-text</li>
        <li>Auto-stop silence detection</li>
        <li>Natural language processing</li>
      </ul>
    </td>
    <td>
      <h3>🎨 Modern UI</h3>
      <ul>
        <li>Animated microphone button</li>
        <li>Live audio visualizer</li>
        <li>Gradient backgrounds</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>
      <h3>🧠 Intelligent Commands</h3>
      <ul>
        <li>Math calculations</li>
        <li>System queries</li>
        <li>App opening (100+ apps)</li>
        <li>Website navigation</li>
      </ul>
    </td>
    <td>
      <h3>🔊 Voice Feedback</h3>
      <ul>
        <li>Text-to-speech responses</li>
        <li>Real-time transcription</li>
        <li>Status indicators</li>
      </ul>
    </td>
  </tr>
</table>

---

## 📱 Demo

### How It Works

```
User taps microphone
         ↓
   Starts listening
         ↓
Speech → Text conversion
         ↓
   Intent parsing
         ↓
  Command execution
         ↓
Voice + UI feedback
```

### Auto-Stop Listening

The app automatically detects when you stop speaking (Siri-like behavior):

- ✅ Listens while you speak
- ✅ Detects 1.5 seconds of silence
- ✅ Executes command automatically
- ✅ No need to tap again!

---

## 🚀 Installation

### Requirements

- **iOS:** 15.0+
- **Xcode:** 14.0+
- **Swift:** 5.9+
 
> ⚠️ **Note:** Speech recognition works best on **physical devices**. Simulator may have limited functionality.

---

## 📖 Usage

### Basic Usage

1. **Tap** the microphone button
2. **Speak** your command naturally
3. **Wait** for auto-detection (1.5 seconds)
4. **Watch** the app execute your command

### Supported Commands

#### 🧮 Math Operations
```
"Add 10 plus 2"        → 12
"Divide 100 by 5"      → 20
"Multiply 3 with 3"    → 9
"Subtract 50 from 100" → 50
```

#### 🕒 System Queries
```
"What time is it"    → Current time
"What is today"      → Current date
"Battery level"      → Battery percentage
```

#### 🌐 Web & Apps
```
"Open YouTube"       → Opens YouTube app/website
"Open WhatsApp"      → Opens WhatsApp
"Open Google.com"    → Opens Google in Safari
"Open Instagram"     → Opens Instagram app
```

#### 🔍 Search & Information
```
"What is capital of India"         → Searches web
"Convert 10,000 INR to USD"        → Currency conversion
"Weather in New York"              → Weather search
```

---

## 🏗️ Project Structure

```
VoiceCommandApp/
│
├── ContentView.swift
│   ├── Main UI interface
│   ├── Microphone button
│   ├── Audio visualizer
│   └── Status displays
│
├── VoiceCommandController.swift
│   ├── Speech recognition engine
│   ├── Audio processing
│   ├── Intent parsing
│   ├── Command execution
│   └── Text-to-speech
│
└── Info.plist
    └── Privacy permissions
```

---

## 🧠 How It Works

### Speech Recognition

Uses Apple's `Speech` framework for real-time transcription:

```swift
let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
```

### Auto-Stop Detection

Implements silence detection timer:

```swift
silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
    self.processCommand(self.recognizedText)
    self.stopListening()
}
```

### Intent Parsing

Commands are processed in priority order:

```swift
1. Math calculations (add, multiply, divide, etc.)
2. System queries (time, date, battery)
3. App/Website opening
4. Web search (fallback)
```

### Audio Visualizer

Real-time audio level detection using RMS:

```swift
let rms = sqrt(frames.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
self.audioLevel = CGFloat(rms)
```

---

## 🎨 UI Components

### Animated Microphone Button

- Pulse animation while listening
- Gradient background (blue → purple)
- Shadow effects with glow

### Live Audio Visualizer

- Concentric rings that respond to voice
- Real-time audio level detection
- Smooth animations

### Status Indicators

- Green dot: Listening
- Gray dot: Idle
- Text feedback: Command results

---

## 📱 Supported Apps (100+)

<details>
<summary>Click to expand full list</summary>

**Social Media**
- WhatsApp, Instagram, Facebook, Twitter/X, Telegram, Snapchat, TikTok, LinkedIn, Reddit, Pinterest

**Entertainment**
- YouTube, Netflix, Spotify, Apple Music, Hulu, Disney+, HBO, Amazon Prime, Twitch, Apple TV

**Productivity**
- Gmail, Outlook, Slack, Zoom, Microsoft Teams, Notion, Trello, Evernote, Dropbox, Google Drive

**Navigation & Travel**
- Google Maps, Waze, Uber, Lyft, Airbnb, Booking.com

**Finance**
- PayPal, Venmo, Cash App, Robinhood, Coinbase

**Health & Fitness**
- Fitbit, Strava, Nike, Peloton, MyFitnessPal, Calm, Headspace

**Gaming**
- Steam, PlayStation, Xbox, Roblox, Minecraft, Fortnite

**Browsers**
- Safari, Chrome, Firefox, Edge, Brave

And many more...

</details>

---

## ⚙️ Configuration

### Adjust Silence Detection Time

In `VoiceCommandController.swift`:

```swift
// Change 1.5 to your preferred seconds
silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false)
```

### Add Custom App Support

Add to the `appSchemes` dictionary:

```swift
"your app name": "yourapp://"
```

### Customize Voice Settings

```swift
let utterance = AVSpeechUtterance(string: text)
utterance.rate = 0.5        // Speech speed
utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
```

---

## 🚫 iOS Limitations

| Limitation | Reason |
|-----------|--------|
| ❌ Cannot open all system apps | Apple security restrictions |
| ❌ Cannot run in background | iOS sandbox limitations |
| ❌ Cannot replace Siri | System-level integration only |
| ❌ Microphone access required | Privacy protection |

**What DOES work:**
- ✅ 100+ third-party apps with URL schemes
- ✅ All websites via Safari
- ✅ Math calculations
- ✅ System queries
- ✅ Web searches
 
