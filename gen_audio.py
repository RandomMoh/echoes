import wave
import math
import struct
import random

def write_wav(filename, samples, sample_rate=44100):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        for s in samples:
            val = int(max(-1.0, min(1.0, s)) * 32767)
            wav_file.writeframes(struct.pack('<h', val))

def generate_dash():
    samples = []
    freq = 800
    for i in range(int(44100 * 0.15)):
        t = i / 44100.0
        wave_val = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
        noise = random.uniform(-1.0, 1.0)
        samples.append((wave_val * 0.5 + noise * 0.5) * (1.0 - t/0.15))
        freq *= 0.998
    write_wav('assets/audio/dash.wav', samples)

def generate_crystal():
    samples = []
    freqs = [1046.50, 1318.51, 1567.98, 2093.00]
    for i in range(int(44100 * 0.2)):
        t = i / 44100.0
        idx = int(t / 0.05)
        if idx > 3: idx = 3
        freq = freqs[idx]
        val = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
        samples.append(val * 0.3 * (1.0 - t/0.2))
    write_wav('assets/audio/crystal.wav', samples)

def generate_bgm(filename, tempo=120, intensity=1):
    samples = []
    pattern = [261.63, 329.63, 392.00, 329.63] if intensity == 1 else \
              [261.63, 392.00, 523.25, 392.00] if intensity == 2 else \
              [523.25, 493.88, 392.00, 329.63, 261.63, 196.00, 164.81, 196.00]
    
    note_duration = 15.0 / tempo
    total_beats = 64
    for b in range(total_beats):
        freq = pattern[b % len(pattern)]
        for i in range(int(44100 * note_duration)):
            t = i / 44100.0
            val = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
            bass_freq = pattern[0] / 2
            bass_val = 1.0 if math.sin(2 * math.pi * bass_freq * t) > 0 else -1.0
            
            if intensity > 1:
                arp_freq = freq * (1.5 if (i // 1000) % 2 == 0 else 1.0)
                val = 1.0 if math.sin(2 * math.pi * arp_freq * t) > 0 else -1.0

            if intensity > 2:
                if b % 2 == 0 and i < 2000:
                    val += random.uniform(-1.5, 1.5)
                    
            mix = (val * 0.3 + bass_val * 0.4) * 0.5
            env = 1.0
            if i > 44100 * note_duration * 0.9:
                env = 1.0 - (i - 44100 * note_duration * 0.9) / (44100 * note_duration * 0.1)
            samples.append(mix * env * 0.2)
    write_wav(filename, samples)

generate_dash()
generate_crystal()
generate_bgm('assets/audio/bgm.wav', tempo=130, intensity=1)
generate_bgm('assets/audio/bgm_level2.wav', tempo=160, intensity=2)
generate_bgm('assets/audio/bgm_level3.wav', tempo=200, intensity=3)
print("Audio generated successfully.")
