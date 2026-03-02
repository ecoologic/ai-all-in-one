#!/usr/bin/env python3
"""
Kokoro TTS — Read a file aloud.

Usage:
  python3 kokoro_read_file.py <filepath>
  python3 kokoro_read_file.py ~/Documents/notes.md
  python3 kokoro_read_file.py report.pdf

Requires: Kokoro FastAPI running on localhost:8880
  docker run -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-cpu:latest
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

import requests

# --- Config ---
KOKORO_URL = "http://localhost:8880/v1/audio/speech"
VOICE = "af_heart"
MODEL = "kokoro"
SPEED = 1.0
MAX_CHARS = 5000


def read_file(path: str) -> str:
    """Read text from a file. Handles common text formats."""
    p = Path(path).expanduser().resolve()

    if not p.exists():
        print(f"Error: file not found: {p}")
        sys.exit(1)

    ext = p.suffix.lower()

    if ext == ".pdf":
        try:
            result = subprocess.run(
                ["pdftotext", str(p), "-"], capture_output=True, text=True, timeout=30
            )
            return result.stdout.strip()
        except FileNotFoundError:
            print("Error: install poppler for PDF support: brew install poppler")
            sys.exit(1)

    if ext == ".docx":
        try:
            from docx import Document
            doc = Document(str(p))
            return "\n".join(para.text for para in doc.paragraphs if para.text.strip())
        except ImportError:
            print("Error: install python-docx for DOCX support: pip install python-docx")
            sys.exit(1)

    try:
        return p.read_text(encoding="utf-8").strip()
    except UnicodeDecodeError:
        return p.read_text(encoding="latin-1").strip()


def speak(text: str):
    """Send text to Kokoro TTS and play."""
    if not text:
        print("No text to read.")
        return

    if len(text) > MAX_CHARS:
        text = text[:MAX_CHARS]
        print(f"Text truncated to {MAX_CHARS} chars.")

    print(f"Sending {len(text)} chars to Kokoro TTS...")

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
        print("Error: cannot connect to Kokoro. Is Docker running?")
        print("  docker run -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-cpu:latest")
        sys.exit(1)
    except requests.RequestException as e:
        print(f"API error: {e}")
        sys.exit(1)

    tmp = tempfile.NamedTemporaryFile(suffix=".mp3", delete=False)
    tmp.write(response.content)
    tmp.close()

    print("Playing...")
    try:
        subprocess.run(["afplay", tmp.name])
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        os.unlink(tmp.name)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 kokoro_read_file.py <filepath>")
        sys.exit(1)

    filepath = sys.argv[1]
    text = read_file(filepath)
    speak(text)


if __name__ == "__main__":
    main()
