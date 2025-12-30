#!/bin/bash

# Directory
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Moods"
mkdir -p "$WALLPAPER_DIR"

# Canvas Size (Oversized to allow rotation without empty corners)
WIDTH=2560
HEIGHT=1600

# Diagonal size approx 3200 for rotation
GEN_SIZE=3200
FINAL_SIZE="${WIDTH}x${HEIGHT}"

echo "Generating Preset Wallpapers using ImageMagick..."

gen_gradient() {
    local name="$1"
    local colors=($2) # Array of colors
    local output="$WALLPAPER_DIR/$name.png"
    
    echo "Creating $name..."
    
    # 1. Create a 1xN pixel image with the colors (Vertical strip)
    # 2. Resize to huge square (smooth gradient)
    # 3. Rotate 45 degrees (ImageMagick rotates clockwise, 0 is right. 
    #    We want 135 deg (TopLeft -> BottomRight). 
    #    Vertical strip is Top->Bottom. 
    #    Rotating -45 (CCW) makes Top->Left (No).
    #    Rotating 45 (CW) makes Top->Right.
    #    Vertical (Top-Bottom) rotated -45 becomes (TopLeft-BottomRight).
    
    # Construct xc:color arguments
    local xc_args=""
    for color in "${colors[@]}"; do
        xc_args="$xc_args xc:$color"
    done
    
    # Execute Convert
    # -size 1x${#colors[@]} : Canvas for input pixels
    # $xc_args -append : Vertical stack
    # -resize ${GEN_SIZE}x${GEN_SIZE}! : Stretch to big square
    # -distort SRT -45 : Rotate to align with 135 degree vector
    # -gravity center -crop ... : Crop to screen size
    
    convert -size 1x${#colors[@]} $xc_args -append \
        -resize "${GEN_SIZE}x${GEN_SIZE}!" \
        -background none -distort SRT -45 \
        -gravity center -crop "$FINAL_SIZE+0+0" +repage \
        "$output"
        
    echo "Saved to $output"
}

# 1. Minimal: "Love, Harmony" (Yellow -> Pink -> Pink)
# colors: ['#ffff00', '#c54b8c', '#c54b8c']
gen_gradient "minimal" "#ffff00 #c54b8c #c54b8c"

# 2. Creative: "Freedom Light..." (Wheat -> Lavender -> Pink -> Red)
# colors: ['#f5deb3', '#ccccff', '#c54b8c', '#eb284f']
gen_gradient "creative" "#f5deb3 #ccccff #c54b8c #eb284f"

# 3. Execution: "Focus & Achievements" (Cyan -> Blue -> Red)
# colors: ['#00ffff', '#007fff', '#eb284f']
gen_gradient "execution" "#00ffff #007fff #eb284f"

# 4. Reflective: "Degrade Negative..." (DarkRed -> Lavender -> Pink -> Yellow)
# colors: ['#b22222', '#ccccff', '#c54b8c', '#ffff00']
gen_gradient "reflective" "#b22222 #ccccff #c54b8c #ffff00"

echo "All wallpapers generated in $WALLPAPER_DIR"
