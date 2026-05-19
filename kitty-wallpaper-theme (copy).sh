#!/usr/bin/env bash
# kitty-wallpaper-theme.sh
# Generates and applies a Kitty terminal color theme based on the dominant
# colors of your current wallpaper.
#
# Dependencies: ImageMagick (convert/identify), kitty
# Optional:     feh, swaybg, swww, hyprpaper, nitrogen, xfconf (for auto-detecting wallpaper)
#
# Usage:
#   ./kitty-wallpaper-theme.sh [wallpaper_path]
#
#   If no path is given, the script tries to detect the current wallpaper
#   from common tools (swaybg, swww, feh, nitrogen, xfconf-query).
#
# The generated theme is written to ~/.config/kitty/wallpaper-theme.conf
# and sourced via kitty's include directive (added automatically on first run).

set -euo pipefail

# ─────────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────────
KITTY_CONF="${KITTY_CONF:-$HOME/.config/kitty/kitty.conf}"
THEME_CONF="${THEME_CONF:-$HOME/.config/kitty/wallpaper-theme.conf}"
NUM_COLORS="${NUM_COLORS:-64}"    # colors to extract before selecting best 8 (more = better coverage)
SAMPLE_SIZE="${SAMPLE_SIZE:-300}" # resize wallpaper to NxN before sampling (speed vs quality)

# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────
die()  { echo "ERROR: $*" >&2; exit 1; }
info() { echo "  → $*"; }

require() {
    for cmd in "$@"; do
        command -v "$cmd" &>/dev/null || die "'$cmd' is required but not installed."
    done
}

hex_to_rgb() {
    # $1 = #RRGGBB  →  prints "R G B"
    local hex="${1#\#}"
    printf "%d %d %d\n" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Perceived luminance (0–255 range)
luminance() {
    local r=$1 g=$2 b=$3
    echo "$(( (r * 299 + g * 587 + b * 114) / 1000 ))"
}

# Lighten or darken a hex color by a percentage (-100..100)
adjust_brightness() {
    local hex="${1#\#}" pct=$2
    local r=$(( 16#${hex:0:2} ))
    local g=$(( 16#${hex:2:2} ))
    local b=$(( 16#${hex:4:2} ))
    r=$(( r + pct * 255 / 100 )); r=$(( r < 0 ? 0 : r > 255 ? 255 : r ))
    g=$(( g + pct * 255 / 100 )); g=$(( g < 0 ? 0 : g > 255 ? 255 : g ))
    b=$(( b + pct * 255 / 100 )); b=$(( b < 0 ? 0 : b > 255 ? 255 : b ))
    printf "#%02x%02x%02x\n" "$r" "$g" "$b"
}

# RGB (0-255 each) → Hue (0-359), Saturation (0-100), Lightness (0-100)
rgb_to_hsl() {
    local r=$1 g=$2 b=$3
    # Use awk for floating-point math
    awk -v r="$r" -v g="$g" -v b="$b" 'BEGIN {
        r /= 255; g /= 255; b /= 255
        max = r > g ? (r > b ? r : b) : (g > b ? g : b)
        min = r < g ? (r < b ? r : b) : (g < b ? g : b)
        l = (max + min) / 2
        d = max - min
        if (d == 0) { h = 0; s = 0 }
        else {
            s = d / (1 - (l > 0.5 ? 2*l-1 : 2*l-1 < 0 ? -(2*l-1) : 2*l-1))
            # simpler s formula:
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
            if      (max == r) { h = (g - b) / d + (g < b ? 6 : 0) }
            else if (max == g) { h = (b - r) / d + 2 }
            else               { h = (r - g) / d + 4 }
            h *= 60
        }
        printf "%d %d %d\n", int(h), int(s*100), int(l*100)
    }'
}

# Blend two hex colors (50/50)
blend() {
    local h1="${1#\#}" h2="${2#\#}"
    local r=$(( (16#${h1:0:2} + 16#${h2:0:2}) / 2 ))
    local g=$(( (16#${h1:2:2} + 16#${h2:2:2}) / 2 ))
    local b=$(( (16#${h1:4:2} + 16#${h2:4:2}) / 2 ))
    printf "#%02x%02x%02x\n" "$r" "$g" "$b"
}

# ─────────────────────────────────────────────
# DETECT WALLPAPER
# ─────────────────────────────────────────────
detect_wallpaper() {
    local wp=""

    # swww (Wayland)
    if command -v swww &>/dev/null; then
        wp=$(swww query 2>/dev/null | grep -oP '(?<=image: ).*' | head -1 || true)
        [[ -f "$wp" ]] && { echo "$wp"; return; }
    fi

    # swaybg / hyprpaper: check common config files
    for cfg in "$HOME/.config/hypr/hyprpaper.conf" "$HOME/.config/swaybg/config"; do
        if [[ -f "$cfg" ]]; then
            wp=$(grep -oP '(?<=wallpaper\s=\s)[^,]+' "$cfg" 2>/dev/null | head -1 | xargs || true)
            [[ -f "$wp" ]] && { echo "$wp"; return; }
        fi
    done

    # feh (X11) — writes ~/.fehbg
    if [[ -f "$HOME/.fehbg" ]]; then
        wp=$(grep -oP "(?<=')([^']+\.(?:png|jpg|jpeg|webp|bmp))" "$HOME/.fehbg" | head -1 || true)
        [[ -f "$wp" ]] && { echo "$wp"; return; }
    fi

    # nitrogen (X11)
    local nitrogen_cfg="$HOME/.config/nitrogen/bg-saved.cfg"
    if [[ -f "$nitrogen_cfg" ]]; then
        wp=$(grep '^file=' "$nitrogen_cfg" | head -1 | cut -d= -f2 || true)
        [[ -f "$wp" ]] && { echo "$wp"; return; }
    fi

    # XFCE
    if command -v xfconf-query &>/dev/null; then
        wp=$(xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image 2>/dev/null || true)
        [[ -f "$wp" ]] && { echo "$wp"; return; }
    fi

    # GNOME
    if command -v gsettings &>/dev/null; then
        wp=$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null \
            | tr -d "'" | sed "s|file://||" || true)
        [[ -f "$wp" ]] && { echo "$wp"; return; }
    fi

    echo ""
}

# ─────────────────────────────────────────────
# EXTRACT PALETTE WITH IMAGEMAGICK
# ─────────────────────────────────────────────
extract_palette() {
    local image="$1" n="$2"

    # histogram:info:- lists each quantized color once.
    # IM6 outputs 8-char hex (#RRGGBBAA); grab only the first 6 chars.
    local result
    result=$(convert "$image" \
        -resize "${SAMPLE_SIZE}x${SAMPLE_SIZE}^" \
        -gravity center -extent "${SAMPLE_SIZE}x${SAMPLE_SIZE}" \
        +dither -colors "$n" \
        -format "%c" histogram:info:- 2>/dev/null \
        | grep -oP '#[0-9A-Fa-f]{6}(?=[^0-9A-Fa-f])' \
        | tr '[:lower:]' '[:upper:]' \
        | sort -u)

    # Fallback: txt: pixel dump (some older IM builds)
    if [[ -z "$result" ]]; then
        result=$(convert "$image" \
            -resize "${SAMPLE_SIZE}x${SAMPLE_SIZE}^" \
            -gravity center -extent "${SAMPLE_SIZE}x${SAMPLE_SIZE}" \
            +dither -colors "$n" txt:- 2>/dev/null \
            | grep -oP '#[0-9A-Fa-f]{6}\b' \
            | tr '[:lower:]' '[:upper:]' \
            | sort -u \
            | head -"$n")
    fi

    [[ -z "$result" ]] && die \
        "ImageMagick could not extract colors from '$image'. Verify it's a valid image."

    echo "$result"
}

# ─────────────────────────────────────────────
# BUILD THEME FROM PALETTE
# ─────────────────────────────────────────────
build_theme() {
    local -a palette=("$@")
    local total=${#palette[@]}

    # ── Step 1: annotate each color with lum + hue ──────────────────────────
    local -a lum_tagged=()   # "lum:hex"  for bg/fg selection
    local -a hue_tagged=()   # "hue:sat:lum:hex"  for accent selection
    for hex in "${palette[@]}"; do
        read -r r g b <<< "$(hex_to_rgb "$hex")"
        local lum; lum=$(luminance "$r" "$g" "$b")
        local hsl;  hsl=$(rgb_to_hsl "$r" "$g" "$b")
        local h s l
        read -r h s l <<< "$hsl"
        lum_tagged+=("${lum}:${hex}")
        hue_tagged+=("${h}:${s}:${lum}:${hex}")
    done

    # ── Step 2: pick bg (darkest) and fg (brightest) by luminance ───────────
    IFS=$'\n' mapfile -t sorted_lum < <(printf '%s\n' "${lum_tagged[@]}" | sort -t: -k1 -n)
    unset IFS

    local bg_hex="${sorted_lum[0]#*:}"
    local fg_hex="${sorted_lum[$((${#sorted_lum[@]}-1))]#*:}"

    read -r bgr bgg bgb <<< "$(hex_to_rgb "$bg_hex")"
    local bg_lum; bg_lum=$(luminance "$bgr" "$bgg" "$bgb")

    local dark_mode=true
    (( bg_lum > 128 )) && dark_mode=false

    local bg fg
    if $dark_mode; then
        bg=$(adjust_brightness "$bg_hex" -10)
        fg=$(adjust_brightness "$fg_hex"  15)
    else
        bg=$(adjust_brightness "$bg_hex"  10)
        fg=$(adjust_brightness "$fg_hex" -15)
    fi

    # ── Step 3: build accent pool — exclude near-black and near-white ────────
    # Keep colors with saturation ≥ 15 and lightness 15–85 (skip greys/extremes)
    local -a accent_pool=()
    for entry in "${hue_tagged[@]}"; do
        IFS=':' read -r h s l hex <<< "$entry"
        if (( s >= 15 && l >= 15 && l <= 85 )); then
            accent_pool+=("${h}:${s}:${l}:${hex}")
        fi
    done

    # Fall back to full palette if wallpaper is desaturated (greyscale photo etc.)
    if (( ${#accent_pool[@]} < 3 )); then
        accent_pool=("${hue_tagged[@]}")
    fi

    # ── Step 4: assign each ANSI slot to a target hue ───────────────────────
    # Done entirely in one awk call to avoid subshell/array-visibility issues.
    # For each target hue, find the closest color in accent_pool by circular
    # hue distance. If the closest is still > tolerance degrees away, shift its
    # hue to the target (keeping S and L from the original).
    #
    # Slots: c1=red(0°) c2=green(120°) c3=yellow(60°)
    #        c4=blue(220°) c5=magenta(300°) c6=cyan(180°)
    read -r c1 c2 c3 c4 c5 c6 <<< "$(
        printf '%s\n' "${accent_pool[@]}" | \
        awk 'BEGIN {
            # target hues and tolerances for each of 6 ANSI accent slots
            split("0 120 60 220 300 180",   targets)
            split("45 50 35 50  50  50",    tols)
            for (i=1;i<=6;i++) { best_dist[i]=999; best_hex[i]="" }
        }
        {
            # input lines: "hue:sat:lum:HEX" — strip leading # from hex
            n = split($0, f, ":")
            if (n < 4) next
            ih = f[1]+0; is_ = f[2]+0; il = f[3]+0
            ihex = f[4]; sub(/^#/, "", ihex)
            for (i=1; i<=6; i++) {
                d = (ih - targets[i] + 360) % 360
                if (d > 180) d = 360 - d
                if (d < best_dist[i]) { best_dist[i]=d; best_hex[i]=ihex }
            }
        }
        END {
            for (i=1; i<=6; i++) {
                hex = best_hex[i]
                if (hex == "") { printf "#808080 "; continue }
                tol = tols[i]+0
                th  = targets[i]+0
                if (best_dist[i] <= tol) {
                    printf "#%s ", hex
                } else {
                    # Shift hue: hex → HLS → new hue → RGB
                    r = ("0x" substr(hex,1,2)) / 255
                    g = ("0x" substr(hex,3,2)) / 255
                    b = ("0x" substr(hex,5,2)) / 255
                    mx = (r>g)?((r>b)?r:b):((g>b)?g:b)
                    mn = (r<g)?((r<b)?r:b):((g<b)?g:b)
                    l  = (mx+mn)/2
                    d  = mx-mn
                    if (d==0) { s=0 } else { s=(l>0.5)?d/(2-mx-mn):d/(mx+mn) }
                    if (s < 0.45) s = 0.45
                    h = th/360
                    q = (l<0.5) ? l*(1+s) : l+s-l*s
                    p = 2*l-q
                    for (j=0; j<3; j++) {
                        t = h + (1-j)*0.333333
                        if (t<0) t+=1; if (t>1) t-=1
                        if      (t<1/6) c=p+(q-p)*6*t
                        else if (t<1/2) c=q
                        else if (t<2/3) c=p+(q-p)*(2/3-t)*6
                        else            c=p
                        if (j==0) r2=c
                        else if (j==1) g2=c
                        else b2=c
                    }
                    printf "#%02x%02x%02x ", int(r2*255), int(g2*255), int(b2*255)
                }
            }
            printf "\n"
        }'
    )"

    # black / white from luminance extremes (always from full palette)
    local lcount=${#sorted_lum[@]}
    local c0="${sorted_lum[0]#*:}"
    local c7="${sorted_lum[$((lcount-1))]#*:}"

    # Ensure c0 is darker than bg and c7 is lighter than fg in dark mode
    if $dark_mode; then
        c0=$(adjust_brightness "$c0" -5)
        c7=$(adjust_brightness "$c7"  5)
    fi

    # ── Step 5: bright variants (evenly lightened / darkened) ─────────────────
    local b0; b0=$(adjust_brightness "$c0" 25)
    local b1; b1=$(adjust_brightness "$c1" 20)
    local b2; b2=$(adjust_brightness "$c2" 20)
    local b3; b3=$(adjust_brightness "$c3" 20)
    local b4; b4=$(adjust_brightness "$c4" 20)
    local b5; b5=$(adjust_brightness "$c5" 20)
    local b6; b6=$(adjust_brightness "$c6" 20)
    local b7; b7=$(adjust_brightness "$c7" 10)

    local selection_bg; selection_bg=$(blend "$c4" "$bg")
    local cursor_color="$c3"

    cat <<EOF
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Kitty theme auto-generated from wallpaper
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Core
background              $bg
foreground              $fg
selection_background    $selection_bg
selection_foreground    $fg
cursor                  $cursor_color
cursor_text_color       $bg
url_color               $c6

# Normal colors
color0                  $c0
color1                  $c1
color2                  $c2
color3                  $c3
color4                  $c4
color5                  $c5
color6                  $c6
color7                  $c7

# Bright colors
color8                  $b0
color9                  $b1
color10                 $b2
color11                 $b3
color12                 $b4
color13                 $b5
color14                 $b6
color15                 $b7

# Tab bar
active_tab_background   $c4
active_tab_foreground   $bg
inactive_tab_background $bg
inactive_tab_foreground $fg
tab_bar_background      $c0
EOF
}

# ─────────────────────────────────────────────
# ENSURE kitty.conf INCLUDES THE THEME FILE
# ─────────────────────────────────────────────
ensure_include() {
    local include_line="include wallpaper-theme.conf"
    mkdir -p "$(dirname "$KITTY_CONF")"
    touch "$KITTY_CONF"
    if ! grep -qF "$include_line" "$KITTY_CONF"; then
        echo "" >> "$KITTY_CONF"
        echo "# Dynamic wallpaper theme (managed by kitty-wallpaper-theme.sh)" >> "$KITTY_CONF"
        echo "$include_line" >> "$KITTY_CONF"
        info "Added 'include wallpaper-theme.conf' to $KITTY_CONF"
    fi
}

# ─────────────────────────────────────────────
# RELOAD KITTY
# ─────────────────────────────────────────────
reload_kitty() {
    if pgrep -x kitty &>/dev/null; then
        kill -SIGUSR1 "$(pgrep -x kitty | head -1)" 2>/dev/null && \
            info "Sent SIGUSR1 to kitty — theme reloaded live." || \
            info "Could not signal kitty; restart it to apply the theme."
    else
        info "Kitty is not running; theme will apply on next launch."
    fi
}

# ─────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────
main() {
    require convert identify

    local wallpaper="${1:-}"

    if [[ -z "$wallpaper" ]]; then
        echo "Detecting current wallpaper..."
        wallpaper=$(detect_wallpaper)
        [[ -z "$wallpaper" ]] && die \
            "Could not auto-detect wallpaper. Pass the path as an argument:\n  $0 /path/to/wallpaper.jpg"
    fi

    [[ -f "$wallpaper" ]] || die "File not found: $wallpaper"

    echo "Wallpaper : $wallpaper"
    echo "Extracting palette (${NUM_COLORS} colors)..."

    mapfile -t palette < <(extract_palette "$wallpaper" "$NUM_COLORS")
    local got=${#palette[@]}
    (( got < 8 )) && die "Only extracted $got colors — image may be too uniform or unsupported."

    info "Extracted $got unique colors."

    echo "Building theme..."
    local theme
    theme=$(build_theme "${palette[@]}")

    echo "Writing theme to $THEME_CONF ..."
    mkdir -p "$(dirname "$THEME_CONF")"
    echo "$theme" > "$THEME_CONF"

    ensure_include
    reload_kitty

    echo ""
    echo "✓ Done! Theme written to:"
    echo "    $THEME_CONF"
    echo ""
    echo "Preview the first few lines:"
    head -20 "$THEME_CONF"
}

main "$@"
