# YourEnviroment
A Swift Scripts that change visual Mac appearance in desired mood.


## Supported Enviroments
- `reflective`
- `execution`
- `minimal`
- `creative`

## How to run
```
./switch_mode.swift <mode>
```


## Based on my personal thoughts and some science backups
The reason behind this is that colors influence us.
The overall picture.

May be other things too but i haven't know it and didn't applied inside Mac.


### Changes to Wallpaper

1. Minimal: "Love, Harmony" (Yellow -> Pink -> Pink)
 - colors: ['#ffff00', '#c54b8c', '#c54b8c']
 - gen_gradient "minimal" "#ffff00 #c54b8c #c54b8c"

3. Creative: "Freedom Light..." (Wheat -> Lavender -> Pink -> Red)
 - colors: ['#f5deb3', '#ccccff', '#c54b8c', '#eb284f']
 - gen_gradient "creative" "#f5deb3 #ccccff #c54b8c #eb284f"

4. Execution: "Focus & Achievements" (Cyan -> Blue -> Red)
 - colors: ['#00ffff', '#007fff', '#eb284f']
 - gen_gradient "execution" "#00ffff #007fff #eb284f"

5. Reflective: "Degrade Negative..." (DarkRed -> Lavender -> Pink -> Yellow)
 - colors: ['#b22222', '#ccccff', '#c54b8c', '#ffff00']
 - gen_gradient "reflective" "#b22222 #ccccff #c54b8c #ffff00"


#### Exact Changes for different Enviroments
 ```
         case .minimal:
            return ModeDescriptor(
                wallpaper: "minimal.png",
                accentColor: 6, // Pink
                reduceTransparency: true,
                reduceMotion: true,
                gammaMode: .normal,
                increaseContrast: false,
                grayscale: false,
                resolution: Resolution(width: 1440, height: 900), // Balanced (16:10)
                obsidianTheme: "Prism" // Clean/Minimal
            )
        case .creative:
            return ModeDescriptor(
                wallpaper: "creative.png",
                accentColor: 2, // Yellow
                reduceTransparency: false,
                reduceMotion: false,
                gammaMode: .sepia,
                increaseContrast: false,
                grayscale: false,
                resolution: Resolution(width: 1680, height: 1050), 
                obsidianTheme: "AnuPpuccin" 
            )
        case .execution:
            return ModeDescriptor(
                wallpaper: "execution.png",
                accentColor: 4, // Blue
                reduceTransparency: true,
                reduceMotion: true,
                gammaMode: .blueTint,
                increaseContrast: true,
                grayscale: false,
                resolution: Resolution(width: 1280, height: 800),
                obsidianTheme: "Olivier’s Theme"
            )
        case .reflective:
            return ModeDescriptor(
                wallpaper: "reflective.png",
                accentColor: 0,
                reduceTransparency: true,
                reduceMotion: true, 
                gammaMode: .dim,
                increaseContrast: true, 
                grayscale: true,
                resolution: Resolution(width: 1680, height: 1050), 
                obsidianTheme: "Prism"
            )

 ```

##### Note
 - You may want to remove obsidian or ignore it
   - let vaultPath = "/Volumes/w/debuglogs/.obsidian/appearance.json"
 - There are hardcoded paths
 - Display Resolution may be unsupported on your Mac
 - You need compile display_controller.c
