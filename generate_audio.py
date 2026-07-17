import math
import struct
import wave
import os

os.makedirs('assets/audio', exist_ok=True)

def generate_wav(filename, samples, sample_rate=44100):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        for s in samples:
            # 16-bit PCM
            val = int(max(-1.0, min(1.0, s)) * 32767)
            wav_file.writeframesraw(struct.pack('<h', val))

def square_wave(freq, t):
    return 0.5 if math.sin(2 * math.pi * freq * t) > 0 else -0.5

def noise(t):
    import random
    return random.uniform(-0.5, 0.5)

# 1. JUMP
sample_rate = 44100
duration = 0.15
samples = []
for i in range(int(sample_rate * duration)):
    t = i / sample_rate
    freq = 200 + (t / duration) * 400 # slide up
    vol = 1.0 - (t / duration)
    samples.append(square_wave(freq, t) * vol * 0.5)
generate_wav('assets/audio/jump.wav', samples)

# 2. ECHO (sonar ping)
duration = 0.4
samples = []
for i in range(int(sample_rate * duration)):
    t = i / sample_rate
    freq = 800 - (t / duration) * 200
    vol = math.exp(-t * 10) # sharp decay
    samples.append(square_wave(freq, t) * vol * 0.4)
generate_wav('assets/audio/echo.wav', samples)

# 3. DEATH (white noise explosion)
duration = 0.5
samples = []
for i in range(int(sample_rate * duration)):
    t = i / sample_rate
    vol = math.exp(-t * 8)
    samples.append(noise(t) * vol * 0.8)
generate_wav('assets/audio/death.wav', samples)

# 4. CHECKPOINT (harmonic chime)
duration = 0.6
samples = []
for i in range(int(sample_rate * duration)):
    t = i / sample_rate
    vol = math.exp(-t * 5)
    # square wave chord (root + fifth)
    s1 = square_wave(440, t)
    s2 = square_wave(660, t)
    samples.append((s1 + s2) * 0.5 * vol * 0.4)
generate_wav('assets/audio/checkpoint.wav', samples)

# 5. WIN (arpeggio)
duration = 1.0
samples = []
notes = [440, 554, 659, 880] # A major arp
for i in range(int(sample_rate * duration)):
    t = i / sample_rate
    note_idx = min(len(notes) - 1, int((t / duration) * len(notes)))
    freq = notes[note_idx]
    vol = 1.0
    if i % (sample_rate * duration / len(notes)) < 1000:
        vol = 0.0 # small gap between notes
    samples.append(square_wave(freq, t) * vol * 0.3)
generate_wav('assets/audio/win.wav', samples)

print("Generated 5 retro sounds!")
