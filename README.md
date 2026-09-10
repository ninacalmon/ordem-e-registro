# Ordem e Registro

*Itch.io link: <https://rossosangue.itch.io/ordem-e-registro>*

[![Godot](https://img.shields.io/badge/Godot-4.5-478cbf)](https://godotengine.org)
[![Language](https://img.shields.io/badge/Language-GDScript-blueviolet)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-critical)](#license)

> You have been assigned to the official registration office following the disappearance of the State registry’s former employees.
> Your duty is to process documents, verify identities, and ensure that the bureaucratic system continues to function smoothly.
> Mistakes will not be tolerated.
> 
> Be efficient, or suffer the consequences

Ordem e Registro is a 2D game about filling out documents under pressure in a dictatorial government.

*This game was created for the Felpojam 2026:* <https://felpojam.com/>

## Table of contents

- [Requirements](#requirements)
- [Project structure](#project-structure)
- [License](#license)
- [Credits](#credits)

## Requirements

Godot 4.5 with the GL Compatibility renderer. Older engine versions will not open the project.

## Project structure

```
res://
├── Global/        # autoloaded singletons (event bus, game state, customer info, level transitions)
├── Scenes/
│   ├── Book/      # the registry book
│   ├── Documents/ # birth certificate, ID card, photo to cut
│   ├── Menu/      # main menu and settings
│   └── game.tscn  # the main scene
├── Scripts/       # shared gameplay modules (cutting, drawing, dragging, focus, image comparison)
├── Particles/     # particle effects
├── Shaders/       # .gdshader files
├── Sounds/        # sound effects
├── Music/         # music tracks
├── Sprites/       # art assets
├── Fonts/         # .ttf fonts
└── Themes/        # .tres themes and color palettes
```

## License

All rights reserved. No open source license applies to this project. Permission to use, modify, or redistribute the code and assets is not granted.

## Credits

Ordem e Registro is made by Nina. Music by Kevin MacLeod and MusicByPedro. Pixel Times font by daymarius.