import wave
import struct
import math
import random

SAMPLE_RATE = 44100
BPM = 120
BEAT_DUR = 60.0 / BPM
VOLUME = 4000

def generate_square_wave(frequency, duration, vol):
    if frequency == 0:
        return [0] * int(duration * SAMPLE_RATE)
    num_samples = int(duration * SAMPLE_RATE)
    audio = []
    period = SAMPLE_RATE / frequency
    for i in range(num_samples):
        # Apply a simple ADSR envelope for a plucked sound
        envelope = 1.0
        if i < 0.05 * SAMPLE_RATE:
            envelope = i / (0.05 * SAMPLE_RATE)
        elif i > num_samples - 0.1 * SAMPLE_RATE:
            envelope = (num_samples - i) / (0.1 * SAMPLE_RATE)
            
        val = vol if (i % period) < (period / 2) else -vol
        audio.append(int(val * envelope))
    return audio

def generate_kick(duration):
    num_samples = int(duration * SAMPLE_RATE)
    audio = []
    for i in range(num_samples):
        # Pitch drop from 150Hz to 40Hz
        freq = 150 - (110 * (i / num_samples))
        val = math.sin(2 * math.pi * freq * (i / SAMPLE_RATE))
        
        envelope = 1.0 - (i / num_samples) ** 2
        audio.append(int(val * VOLUME * 2 * envelope))
    return audio

def generate_hihat(duration):
    num_samples = int(duration * SAMPLE_RATE)
    audio = []
    for i in range(num_samples):
        val = random.uniform(-1, 1)
        # Fast decay
        envelope = math.exp(-30 * (i / SAMPLE_RATE))
        audio.append(int(val * VOLUME * 0.8 * envelope))
    return audio

# Frequencies for A minor pentatonic: A, C, D, E, G
# Bassline: A2 (110), F2 (87.31), C3 (130.81), G2 (98.00)
bass_progression = [
    (110.00, BEAT_DUR * 4),
    (87.31, BEAT_DUR * 4),
    (130.81, BEAT_DUR * 4),
    (98.00, BEAT_DUR * 4)
]

melody_notes = [220.00, 261.63, 293.66, 329.63, 392.00, 440.00, 523.25]

final_audio = [0] * int(BEAT_DUR * 16 * SAMPLE_RATE)

# Generate 16 beats (4 bars)
current_sample = 0
for bar in range(4):
    bass_freq, duration = bass_progression[bar]
    
    # 4 beats per bar
    for beat in range(4):
        # Bass rhythm (8th notes)
        for eighth in range(2):
            bass_wave = generate_square_wave(bass_freq, BEAT_DUR / 2, VOLUME * 0.6)
            for i, val in enumerate(bass_wave):
                if current_sample + i < len(final_audio):
                    final_audio[current_sample + i] += val
            
            # Drums
            if eighth == 0 and (beat == 0 or beat == 2):
                drum = generate_kick(BEAT_DUR / 2)
                for i, val in enumerate(drum):
                    if current_sample + i < len(final_audio):
                        final_audio[current_sample + i] += val
                        
            hihat = generate_hihat(BEAT_DUR / 2)
            for i, val in enumerate(hihat):
                if current_sample + i < len(final_audio):
                    final_audio[current_sample + i] += val
            
            # Arpeggiator melody
            note = random.choice(melody_notes)
            melody = generate_square_wave(note, BEAT_DUR / 2, VOLUME * 0.4)
            for i, val in enumerate(melody):
                if current_sample + i < len(final_audio):
                    final_audio[current_sample + i] += val
                    
            current_sample += int(BEAT_DUR / 2 * SAMPLE_RATE)

# Write to file
with wave.open('assets/audio/bgm.wav', 'w') as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(SAMPLE_RATE)
    for sample in final_audio:
        sample = max(-32768, min(32767, sample)) # Hard clip
        wav_file.writeframes(struct.pack('h', sample))
