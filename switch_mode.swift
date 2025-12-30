#!/usr/bin/env swift
import Cocoa
import CoreFoundation
import CoreGraphics
import Foundation

// MARK: - Configuration
let wallpapersDir = NSString(string: "~/Pictures/Wallpapers/Moods").expandingTildeInPath

// Mode Definitions
enum Mode: String, CaseIterable {
    case minimal
    case creative
    case execution
    case reflective

    var descriptor: ModeDescriptor {
        switch self {
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
                resolution: Resolution(width: 1680, height: 1050), // Max Space (16:10)
                obsidianTheme: "AnuPpuccin" // Colorful/Customizable
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
                resolution: Resolution(width: 1280, height: 800), // Focus/Large Text (16:10)
                obsidianTheme: "Olivier’s Theme" // Professional/Focus
            )
        case .reflective:
            return ModeDescriptor(
                wallpaper: "reflective.png", // Keep the dark red/green art
                accentColor: 0, // Red (The Pen is still Mars)
                reduceTransparency: true, 
                reduceMotion: true, // Stillness is required for reflection
                gammaMode: .dim, // OR .grayscale if your tool supports it
                increaseContrast: true, // Sharp edges = Sharp truth
                grayscale: true, // <--- THIS is the key
                resolution: Resolution(width: 1680, height: 1050), // Balanced (16:10)
                obsidianTheme: "Prism"
            )
        }
    }
}

enum GammaMode {
    case normal
    case redOnly
    case blueTint
    case sepia
    case dim
}

struct Resolution {
    let width: Int
    let height: Int
}

struct ModeDescriptor {
    let wallpaper: String
    let accentColor: Int
    let reduceTransparency: Bool
    let reduceMotion: Bool
    let gammaMode: GammaMode
    let increaseContrast: Bool
    let grayscale: Bool
    let resolution: Resolution? 
    let obsidianTheme: String? // Name of the theme (e.g., "Prism")
}

// MARK: - Main Logic

func setWallpaper(filename: String) {
    let url = URL(fileURLWithPath: "\(wallpapersDir)/\(filename)")
    guard FileManager.default.fileExists(atPath: url.path) else {
        print("✗ Wallpaper file not found: \(url.path)")
        print("  (Tip: Run ./generate_preset_wallpapers.sh)")
        return
    }
    
    do {
        for screen in NSScreen.screens {
            try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        }
        print("✓ Wallpaper set to \(filename)")
    } catch {
        print("✗ Failed to set wallpaper: \(error)")
    }
}

func setAccentColor(id: Int) {
    let key = "AppleAccentColor" as CFString
    CFPreferencesSetValue(key, id as CFNumber, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
    CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
    
    DistributedNotificationCenter.default().postNotificationName(NSNotification.Name("AppleColorPreferencesChangedNotification"), object: nil, userInfo: nil, deliverImmediately: true)
    DistributedNotificationCenter.default().postNotificationName(NSNotification.Name("AppleAquaColorVariantChanged"), object: nil, userInfo: nil, deliverImmediately: true)
    print("✓ Accent Color set to ID \(id)")
}

func setResolution(res: Resolution?) {
    guard let r = res else { return }
    
    // Resolve Tool Path (Robustly)
    let scriptPath = CommandLine.arguments[0]
    let scriptURL = URL(fileURLWithPath: scriptPath)
    let toolURL = scriptURL.deletingLastPathComponent().appendingPathComponent("display_control")
    
    guard FileManager.default.fileExists(atPath: toolURL.path) else {
        print("⚠️  Error: Could not find 'display_control' at \(toolURL.path)")
        return
    }
    
    let process = Process()
    process.executableURL = toolURL
    process.arguments = ["res", "\(r.width)", "\(r.height)"]
    
    do {
        try process.run()
        process.waitUntilExit()
        // display_control prints result, so we don't need to duplicate success msg unless we want to
    } catch {
        print("✗ Failed to set resolution: \(error)")
    }
}

func setObsidianTheme(name: String?) {
    guard let themeName = name else { return }
    let vaultPath = "/Volumes/w/debuglogs/.obsidian/appearance.json"
    let url = URL(fileURLWithPath: vaultPath)
    
    do {
        // 1. Read Data
        let data = try Data(contentsOf: url)
        // 2. Parse JSON to Dictionary
        guard var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("✗ Failed to parse appearance.json")
            return
        }
        
        // 3. Update Theme
        json["cssTheme"] = themeName
        
        // 4. Write Back
        let newData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try newData.write(to: url)
        print("✓ Obsidian Theme set to '\(themeName)'")
        
        // 5. Trigger Reload (Cmd+R) leave it for now
        // reloadObsidian()
        
    } catch {
        print("✗ Failed to set Obsidian theme: \(error)")
    }
}

func reloadObsidian() {
    let script = """
    tell application "Obsidian" to activate
    tell application "System Events"
        tell process "Obsidian"
            keystroke "r" using command down
        end tell
    end tell
    """
    
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    process.arguments = ["-e", script]
    try? process.run()
    // process.waitUntilExit() // Don't block
    print("✓ Triggered Obsidian Reload")
}

func setGamma(mode: GammaMode) {
    // 1. Resolve Tool Path (Robustly)
    // Find 'display_control' in the same directory as this script
    let scriptPath = CommandLine.arguments[0]
    let scriptURL = URL(fileURLWithPath: scriptPath)
    let toolURL = scriptURL.deletingLastPathComponent().appendingPathComponent("display_control")
    
    guard FileManager.default.fileExists(atPath: toolURL.path) else {
        print("⚠️  Error: Could not find 'display_control' at \(toolURL.path)")
        print("    Please compile it: clang -framework ApplicationServices tools/display_control.c -o tools/display_control")
        return
    }

    // 2. PID Management (Surgical Kill)
    let pidPath = "/tmp/display_control.pid"
    if FileManager.default.fileExists(atPath: pidPath) {
        do {
            let pidString = try String(contentsOfFile: pidPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
            if let pid = Int32(pidString) {
                // Check if process exists (signal 0)
                if kill(pid, 0) == 0 {
                    // Send SIGTERM
                    kill(pid, SIGTERM)
                    // Clean up pid file
                    try? FileManager.default.removeItem(atPath: pidPath)
                }
            }
        } catch {
            print("Warning: Failed to parse/kill old PID: \(error)")
        }
    }

    // 3. Prepare Arguments
    let modeArg: String
    switch mode {
    case .redOnly: modeArg = "red"
    case .blueTint: modeArg = "blue"
    case .sepia: modeArg = "sepia"
    case .dim: modeArg = "dim" // Updated to match display_control.c
    default: modeArg = "normal"
    }
    
    // 4. Launch Process
    // For 'normal', we run synchronously to reset.
    // For others, we run asynchronously (daemon).
    
    let process = Process()
    process.executableURL = toolURL
    process.arguments = ["gamma", modeArg]
    
    if mode == .normal {
        try? process.run()
        process.waitUntilExit()
        print("✓ Gamma reset to normal")
    } else {
        do {
            try process.run()
            let newPid = process.processIdentifier
            print("✓ Gamma set to \(modeArg) (PID: \(newPid))")
            
            // Save PID
            try String(newPid).write(toFile: pidPath, atomically: true, encoding: .utf8)
        } catch {
            print("✗ Failed to launch display_control: \(error)")
        }
    }
}

func setAccessibility(reduceTransparency: Bool, reduceMotion: Bool, increaseContrast: Bool, grayscale: Bool) {
    // We execute the User's specific Shortcuts
    let transparencyShortcut = reduceTransparency ? "On Transparency Mode" : "Off Reduce Transparency"
    let contrastShortcut = increaseContrast ? "Increase Contrast to on" : "Increase Contrast to off"
    let grayscaleShortcut = grayscale ? "greyscale on" : "greyscale off"
    
    runShortcut(name: transparencyShortcut)
    runShortcut(name: contrastShortcut)
    runShortcut(name: grayscaleShortcut)
    
    // Reduce Motion - User hasn't shown a shortcut for this yet, so we keep it optional or just print
    if reduceMotion {
        // print("Tip: Create 'Reduce Motion On' shortcut for full effect.")
    }
}

func runShortcut(name: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
    process.arguments = ["run", name]
    
    do {
        try process.run()
        process.waitUntilExit()
        print("✓ Ran Shortcut: '\(name)'")
    } catch {
        print("✗ Failed to run shortcut '\(name)': \(error)")
    }
}

// MARK: - CLI
let args = CommandLine.arguments

guard args.count > 1 else {
    print("Usage: switch_mode <mode>")
    print("Modes: \(Mode.allCases.map { $0.rawValue }.joined(separator: ", "))")
    exit(1)
}

guard let mode = Mode(rawValue: args[1].lowercased()) else {
    print("Unknown mode: \(args[1])")
    exit(1)
}

print("== Switching to \(mode.rawValue.uppercased()) Mode ==")
let descriptor = mode.descriptor

// 1. Wallpaper
setWallpaper(filename: descriptor.wallpaper)

// 2. Accent
setAccentColor(id: descriptor.accentColor)

// 3. Resolution
setResolution(res: descriptor.resolution)

// 4. Obsidian Theme
setObsidianTheme(name: descriptor.obsidianTheme)

// 5. Gamma (Hardware Colors)
setGamma(mode: descriptor.gammaMode)

// 4. Accessibility (Via Shortcuts)
setAccessibility(
    reduceTransparency: descriptor.reduceTransparency, 
    reduceMotion: descriptor.reduceMotion, 
    increaseContrast: descriptor.increaseContrast,
    grayscale: descriptor.grayscale
)

print("== Done ==")
