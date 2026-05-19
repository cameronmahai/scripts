#!/bin/bash

# Gemini ASCII Stick Figure Runner

# Hide cursor
tput civis

# Trap to restore cursor and clear screen on exit
trap "stty echo; tput cnorm; clear; exit" SIGINT SIGTERM

# Terminal dimensions
COLS=$(tput cols)
LINES=$(tput lines)

# Ground level
GROUND=$((LINES - 4))
PLAYER_X=15
player_y=$GROUND
score=0
score_granted=1

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

stty -echo
clear
echo "Gemini Stick Runner"
echo "-------------------"
echo "Press SPACE to Jump"
echo "Press Ctrl+C to Quit"
echo ""
for i in {3..1}; do
    echo -ne "\rStarting in $i... "
    sleep 1
done
echo -ne "\rGO!             "
sleep 0.5

while true; do
    # 0. Handle Input (Non-blocking)
    IFS= read -rs -n 1 -t 0.001 key
    if [[ "$key" == " " ]] && [ $jump_state -eq 0 ]; then
        jump_state=1
    fi

    # 1. Update Positions
    # Obstacle
    if [ $obstacle_x -lt -5 ]; then
        if [ $((RANDOM % 5)) -eq 0 ]; then
             obstacle_x=$((COLS - 5))
             score_granted=0
        fi
    else
        obstacle_x=$((obstacle_x - 3))
    fi

    # Scoring
    if [ $obstacle_x -lt $PLAYER_X ] && [ $score_granted -eq 0 ]; then
        score=$((score + 1))
        score_granted=1
    fi

    # Cloud (slower)
    cloud_x=$((cloud_x - 1))
    [ $cloud_x -lt -10 ] && cloud_x=$COLS

    # 2. Update Jump Physics
    if [ $jump_state -gt 0 ]; then
        case $jump_state in
            1|12) offset=1 ;; 2|11) offset=2 ;; 3|10) offset=3 ;;
            4|9)  offset=4 ;; 5|8)  offset=5 ;; 6|7)  offset=6 ;;
        esac
        player_y=$((GROUND - offset))
        jump_state=$((jump_state + 1))
        [ $jump_state -gt 12 ] && jump_state=0 && player_y=$GROUND
    fi

    # 3. Collision Detection
    # Obstacle is 5 chars wide [XXX]
    # Player is at PLAYER_X (approx 5 chars wide)
    if [ $obstacle_x -ge $((PLAYER_X - 4)) ] && [ $obstacle_x -le $((PLAYER_X + 4)) ]; then
        # If player is not high enough
        if [ $((GROUND - player_y)) -lt 2 ]; then
            echo -ne "\033[$((GROUND - 5));$((COLS / 2 - 10))H\033[1;31m  GAME OVER!  \033[0m"
            echo -ne "\033[$((GROUND - 4));$((COLS / 2 - 10))H\033[1;37m Final Score: $score \033[0m"
            echo -ne "\033[$((GROUND - 2));$((COLS / 2 - 10))H Press any key to exit... "
            tput cnorm
            read -n 1
            exit
        fi
    fi

    # 4. Render
    echo -ne "\033[H" # Go home
    
    # Clear lines where we draw
    for y in $(seq 3 $((GROUND + 1))); do
        echo -ne "\033[${y};1H\033[K"
    done

    # Draw Score
    echo -ne "\033[2;2HScore: $score"

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
