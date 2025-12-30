# YourEnviroment
A Swift Scripts that change visual Mac appearance in desired mood.


### Supported Enviroments
- `reflective`
- `execution`
- `minimal`
- `creative`

### Based on my personal thoughts and some science backups
The reason behind this is that colors influence us.
The overall picture.

May be other things too but i haven't know it and didn't applied inside MAC.

##### Exact Changes for different Enviroments
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
