# Echoes

I built Echoes because I wanted an old-school arcade platformer that actually pushes back. It's a 2D infinite runner made with Flutter and the Flame engine, and the difficulty curve doesn't mess around.

## Mechanics

You jump between platforms, dodge spikes, and try not to fall off the screen as the game accelerates. The procedural generation starts throwing moving platforms, wide gaps, and crumbling floors at you pretty early on. You also have an active sonar ping mechanic to light up dark sections of the map. By level 5, the terrain gets actively hostile.

To make the risk-reward math a little harder, blue crystals start spawning at level 3. They're rare, usually placed over pits, and grab you 500 points if you survive the jump. Since the later levels burn through your lives quickly, I also scattered a few heart pickups into the generation pool to help you stretch a run slightly further.

## Tech Stack

The game runs on Flutter. I used:
* **Flame** for the core game loop and collision physics
* **Flame Audio** to handle the retro SFX and gapless background music
* **Google Fonts (PressStart2P)** for the arcade typography
* **Shared Preferences** to persist high scores locally

## Running the game

If you have the Flutter SDK set up, you can compile the project or run it straight on an emulator.

```bash
flutter pub get
flutter run
```

If you don't want to deal with compiling it, I keep prebuilt APKs in the `game_apks/` directory. Just drop the latest release onto an Android phone and install it.
