# Echoes

Echoes is a 2D infinite runner and platformer built with Flutter and the Flame engine. I wanted to make an old school arcade style game that actually gets hard as you play it.

## How it works

You jump between platforms, avoid spikes, and try to survive as the game speeds up. The level generation throws moving platforms at you to cover large gaps. It starts out simple but gets pretty punishing by the time you reach level 5. 

We added blue crystals starting at level 3. If you manage to grab one without falling into a pit, you get 500 points. They only spawn a couple of times per level, so they are actually worth going out of your way for. 

Because the later levels get so difficult, we also put in collectible hearts. They restore one life point. They use a classic retro animation and sound effect when you pick them up. 

## Tech stack

The game runs on Flutter. I used:
* Flame for the core game loop and physics
* Flame Audio for sound effects and background music
* Google Fonts (PressStart2P) for the retro text look
* Shared Preferences to save high scores

## Running the project

If you have Flutter installed, you can build the APK or run it directly on an emulator or device. 

```bash
flutter pub get
flutter run
```

There are also prebuilt APK files in the `game_apks/` directory if you just want to install and play it on an Android phone.
