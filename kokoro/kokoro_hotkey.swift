import Cocoa
import Foundation

// --- Config ---
let kokoroURL = "http://localhost:8880/v1/audio/speech"
let voice = "af_heart"
let model = "kokoro"
let speed = 1.0
let maxChars = 5000

// --- State ---
var afplayProcess: Process?
let lock = NSLock()

func isPlaying() -> Bool {
    lock.lock()
    defer { lock.unlock() }
    return afplayProcess?.isRunning ?? false
}

func stopPlayback() -> Bool {
    lock.lock()
    defer { lock.unlock() }
    if let proc = afplayProcess, proc.isRunning {
        proc.terminate()
        afplayProcess = nil
        showNotification("Playback stopped")
        return true
    }
    return false
}

func showNotification(_ message: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    task.arguments = ["-e", "display notification \"\(message)\" with title \"Kokoro TTS\""]
    try? task.run()
}

func getClipboard() -> String? {
    let pb = NSPasteboard.general
    return pb.string(forType: .string)
}

func copySelection() {
    // Simulate Cmd+C via AppleScript
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    task.arguments = ["-e", "tell application \"System Events\" to keystroke \"c\" using command down"]
    try? task.run()
    task.waitUntilExit()
    Thread.sleep(forTimeInterval: 0.3)
}

func speak(_ text: String) {
    var text = text
    if text.isEmpty {
        showNotification("No text to read")
        return
    }

    if text.count > maxChars {
        text = String(text.prefix(maxChars))
        showNotification("Text truncated to \(maxChars) chars")
    }

    showNotification("Reading \(text.count) characters...")

    // Build JSON payload
    let payload: [String: Any] = [
        "model": model,
        "input": text,
        "voice": voice,
        "speed": speed,
        "response_format": "mp3"
    ]

    guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
          let url = URL(string: kokoroURL) else {
        showNotification("Failed to build request")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 120

    let sem = DispatchSemaphore(value: 0)
    var audioData: Data?
    var requestError: String?

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            requestError = error.localizedDescription
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            requestError = "HTTP \(httpResponse.statusCode)"
        } else {
            audioData = data
        }
        sem.signal()
    }.resume()

    sem.wait()

    if let err = requestError {
        showNotification("Error: \(err)")
        return
    }

    guard let data = audioData else {
        showNotification("No audio data received")
        return
    }

    // Write to temp file
    let tmpFile = NSTemporaryDirectory() + "kokoro_\(ProcessInfo.processInfo.processIdentifier).mp3"
    let tmpURL = URL(fileURLWithPath: tmpFile)

    do {
        try data.write(to: tmpURL)
    } catch {
        showNotification("Failed to write temp file")
        return
    }

    // Stop any existing playback
    _ = stopPlayback()

    // Play with afplay
    let afplay = Process()
    afplay.executableURL = URL(fileURLWithPath: "/usr/bin/afplay")
    afplay.arguments = [tmpFile]

    lock.lock()
    afplayProcess = afplay
    lock.unlock()

    do {
        try afplay.run()
    } catch {
        showNotification("Failed to play audio")
        return
    }

    // Clean up in background after playback
    DispatchQueue.global().async {
        afplay.waitUntilExit()
        try? FileManager.default.removeItem(at: tmpURL)
    }
}

func onToggle() {
    if isPlaying() {
        _ = stopPlayback()
    } else {
        DispatchQueue.global().async {
            copySelection()
            if let text = getClipboard(), !text.isEmpty {
                speak(text)
            } else {
                showNotification("No text selected")
            }
        }
    }
}

// --- Global hotkey via CGEvent tap ---
func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .keyDown {
        let keycode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        // Keycode 49 = Space, check for Ctrl modifier (no other modifiers)
        if keycode == 49 && flags.contains(.maskControl)
            && !flags.contains(.maskShift)
            && !flags.contains(.maskCommand)
            && !flags.contains(.maskAlternate) {
            onToggle()
            return nil  // Swallow the event
        }
    }

    // Re-enable tap if disabled by system
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let refcon = refcon {
            let tap = Unmanaged<CFMachPort>.fromOpaque(refcon).takeUnretainedValue()
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }

    return Unmanaged.passRetained(event)
}

func main() {
    print("==============================================")
    print("  Kokoro TTS")
    print("==============================================")
    print()
    print("  Ctrl+Space  — Toggle read selected / stop")
    print("  Ctrl+C      — Quit")
    print()

    guard let eventTap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
        callback: eventCallback,
        userInfo: nil
    ) else {
        print("ERROR: Failed to create event tap.")
        print("Grant Accessibility permission to this app:")
        print("  System Settings → Privacy & Security → Accessibility")
        exit(1)
    }

    // Pass tap reference for re-enabling
    let tapPointer = Unmanaged.passUnretained(eventTap).toOpaque()
    guard let updatedTap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
        callback: eventCallback,
        userInfo: tapPointer
    ) else {
        print("ERROR: Failed to create event tap.")
        exit(1)
    }

    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, updatedTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: updatedTap, enable: true)

    showNotification("Hotkey listener active")
    print("  Listening for Ctrl+Space...")
    print()

    CFRunLoopRun()
}

main()
