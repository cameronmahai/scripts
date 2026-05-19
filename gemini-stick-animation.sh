#!/bin/bash

# Gemini ASCII Stick Figure Runner

# Hide cursor
tput civis

# Trap to restore cursor and clear screen on exit
trap "tput cnorm; clear; exit" SIGINT SIGTERM

# Terminal dimensions
COLS=$(tput cols)
LINES=$(tput lines)

# Ground level
GROUND=$((LINES - 4))
PLAYER_X=15
player_y=$GROUND

# Animation state
jump_state=0
frames_count=0
obstacle_x=-1
cloud_x=$COLS

# Pre-generate ground line
GROUND_LINE=$(printf '_%.0s' $(seq 1 $COLS))

# Stick Figure Frames
run1_1="  O  "; run1_2=" /|\\ "; run1_3=" / \\ "
run2_1="  O  "; run2_2=" /|\\ "; run2_3="  |\\ "
run3_1="  O  "; run3_2=" /|\\ "; run3_3=" /|  "
jump_1="  O  "; jump_2=" /|\\ "; jump_3=" / \\ "

clear
echo "Gemini Stick Runner - Press Ctrl+C to stop"

while true; do
    # 1. Update Positions
    # Obstacle
    if [ $obstacle_x -lt 0 ]; then
        [ $((RANDOM % 5)) -eq 0 ] && obstacle_x=$((COLS - 5))
    else
        obstacle_x=$((obstacle_x - 3))
    fi

    # Cloud (slower)
    cloud_x=$((cloud_x - 1))
    [ $cloud_x -lt -10 ] && cloud_x=$COLS

    # 2. Update Jump Physics
    if [ $jump_state -eq 0 ] && [ $obstacle_x -gt $PLAYER_X ] && [ $obstacle_x -lt $((PLAYER_X + 15)) ]; then
        jump_state=1
    fi

    if [ $jump_state -gt 0 ]; then
        case $jump_state in
            1|12) offset=1 ;; 2|11) offset=2 ;; 3|10) offset=3 ;;
            4|9)  offset=4 ;; 5|8)  offset=5 ;; 6|7)  offset=6 ;;
        esac
        player_y=$((GROUND - offset))
        jump_state=$((jump_state + 1))
        [ $jump_state -gt 12 ] && jump_state=0 && player_y=$GROUND
    fi

    # 3. Render
    echo -ne "\033[H" # Go home
    
    # Clear lines where we draw (to avoid artifacts)
    for y in $(seq 3 $((GROUND + 1))); do
        echo -ne "\033[${y};1H\033[K"
    done

    # Draw Ground
    echo -ne "\033[${GROUND};1H${GROUND_LINE}"

    # Draw Cloud
    if [ $cloud_x -gt 0 ] && [ $cloud_x -lt $((COLS - 10)) ]; then
        echo -ne "\033[5;${cloud_x}H(  )  (   )"
        echo -ne "\033[6;$((cloud_x + 2))H(       )"
    fi

    # Draw Obstacle
    if [ $obstacle_x -gt 0 ] && [ $obstacle_x -lt $COLS ]; then
        echo -ne "\033[$((GROUND - 1));${obstacle_x}H[XXX]"
        echo -ne "\033[${GROUND};${obstacle_x}H[XXX]"
    fi

    # Select Player Frame
    if [ $jump_state -gt 0 ]; then
        p1="$jump_1"; p2="$jump_2"; p3="$jump_3"
    else
        case $(( (frames_count / 2) % 3 )) in
            0) p1="$run1_1"; p2="$run1_2"; p3="$run1_3" ;;
            1) p1="$run2_1"; p2="$run2_2"; p3="$run2_3" ;;
            2) p1="$run3_1"; p2="$run3_2"; p3="$run3_3" ;;
        esac
    fi

    # Draw Player
    echo -ne "\033[$((player_y - 2));${PLAYER_X}H$p1"
    echo -ne "\033[$((player_y - 1));${PLAYER_X}H$p2"
    echo -ne "\033[${player_y};${PLAYER_X}H$p3"

    frames_count=$((frames_count + 1))
    sleep 0.04
done
