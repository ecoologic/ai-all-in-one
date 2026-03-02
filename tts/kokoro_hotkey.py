#!/usr/bin/env python3
"""
Kokoro TTS Hotkey Reader
========================
Global hotkey to read text aloud via local Kokoro TTS Docker container.

Hotkeys:
  Ctrl+Space    — Toggle: read selected text / stop playback
  Ctrl+Shift+Q  — Quit

For reading files, use the separate CLI command:
  python3 kokoro_read_file.py <filepath>

Requires: Kokoro FastAPI running on localhost:8880
  docker run -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-cpu:latest
"""

import os
import signal
import subprocess
import tempfile
import threading
import time

import requests
from pynput import keyboard
from pynput.keyboard import Key, Controller

# --- Config ---
KOKORO_URL = "http://localhost:8880/v1/audio/speech"
VOICE = "af_heart"  # Default Kokoro voice
MODEL = "kokoro"
SPEED = 1.0
MAX_CHARS = 5000  # Chunk size to avoid overloading the API

kb_controller = Controller()
playback_process = None
playback_lock = threading.Lock()


def notify(title: str, message: str):
    """macOS notification via osascript."""
    try:
        subprocess.run(
            ["osascript", "-e", f'display notification "{message}" with title "{title}"'],
            timeout=3,
        )
    except Exception:
        print(f"[{title}] {message}")


def get_clipboard() -> str:
    """Read clipboard contents on macOS."""
    result = subprocess.run(["pbpaste"], capture_output=True, text=True, timeout=5)
    return result.stdout.strip()


def copy_selection():
    """Simulate Cmd+C to copy selected text to clipboard."""
    time.sleep(0.1)
    kb_controller.press(Key.cmd)
    kb_controller.press(keyboard.KeyCode.from_char("c"))
    kb_controller.release(keyboard.KeyCode.from_char("c"))
    kb_controller.release(Key.cmd)
    time.sleep(0.3)


def is_playing() -> bool:
    """Check if audio is currently playing."""
    with playback_lock:
        return playback_process is not None and playback_process.poll() is None


def stop_playback():
    """Stop any currently playing audio. Returns True if something was stopped."""
    global playback_process
    with playback_lock:
        if playback_process and playback_process.poll() is None:
            playback_process.terminate()
            playback_process = None
            notify("Kokoro TTS", "Playback stopped")
            return True
        return False


def speak(text: str):
    """Send text to Kokoro TTS and play the audio."""
    global playback_process

    if not text:
        notify("Kokoro TTS", "No text to read")
        return

    if len(text) > MAX_CHARS:
        text = text[:MAX_CHARS]
        notify("Kokoro TTS", f"Text truncated to {MAX_CHARS} chars")

    notify("Kokoro TTS", f"Reading {len(text)} characters...")

    try:
        response = requests.post(
            KOKORO_URL,
            json={
                "model": MODEL,
                "input": text,
                "voice": VOICE,
                "speed": SPEED,
                "response_format": "mp3",
            },
            headers={"Content-Type": "application/json"},
            timeout=120,
        )
        response.raise_for_status()
    except requests.ConnectionError:
        notify("Kokoro TTS", "Cannot connect. Is Docker container running?")
        return
    except requests.RequestException as e:
        notify("Kokoro TTS", f"API error: {e}")
        return

    stop_playback()

    tmp = tempfile.NamedTemporaryFile(suffix=".mp3", delete=False)
    tmp.write(response.content)
    tmp.close()

    with playback_lock:
        playback_process = subprocess.Popen(
            ["afplay", tmp.name],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    def cleanup():
        playback_process.wait()
        try:
            os.unlink(tmp.name)
        except OSError:
            pass

    threading.Thread(target=cleanup, daemon=True).start()


def on_toggle():
    """Ctrl+Space handler: stop if playing, otherwise read selection."""
    if is_playing():
        stop_playback()
    else:
        def _run():
            copy_selection()
            text = get_clipboard()
            speak(text)
        threading.Thread(target=_run, daemon=True).start()


# Track pressed keys for Ctrl+Space (GlobalHotKeys doesn't support <space>)
pressed_keys = set()


def on_press(key):
    pressed_keys.add(key)
    if Key.ctrl_l in pressed_keys or Key.ctrl_r in pressed_keys:
        if key == Key.space:
            on_toggle()
    if Key.ctrl_l in pressed_keys or Key.ctrl_r in pressed_keys:
        if Key.shift_l in pressed_keys or Key.shift_r in pressed_keys:
            if hasattr(key, "char") and key.char == "q":
                os._exit(0)


def on_release(key):
    pressed_keys.discard(key)


def main():
    print("=" * 50)
    print("  Kokoro TTS Hotkey Reader")
    print("=" * 50)
    print()
    print("  Ctrl+Space    — Toggle read/stop")
    print("  Ctrl+Shift+Q  — Quit")
    print()
    print("  Listening for hotkeys...")
    print()

    listener = keyboard.Listener(on_press=on_press, on_release=on_release)
    listener.start()

    notify("Kokoro TTS", "Hotkey listener active")

    try:
        signal.pause()
    except AttributeError:
        while True:
            time.sleep(1)


if __name__ == "__main__":
    main()
