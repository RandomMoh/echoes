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

def generate_better_dash():
    samples = []
    # 8-bit noise whoosh
    for i in range(int(44100 * 0.25)):
        t = i / 44100.0
        # generate 8-bit noise (quantized random)
        noise = random.choice([-1.0, 1.0])
        env = math.exp(-t * 20)
        samples.append(noise * env * 0.4)
    write_wav('assets/audio/dash.wav', samples)

def generate_better_crystal():
    samples = []
    # Classic coin: B5 (987.77) for 0.05s, then E6 (1318.51) for 0.25s
    for i in range(int(44100 * 0.3)):
        t = i / 44100.0
        freq = 987.77 if t < 0.05 else 1318.51
        val = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
        env = math.exp(-t * 10)
        samples.append(val * env * 0.3)
    write_wav('assets/audio/crystal.wav', samples)

generate_better_dash()
generate_better_crystal()
