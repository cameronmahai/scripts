# Show the raw colors ImageMagick extracts before any processing
convert your-wallpaper.jpg \
    -resize 300x300^ -gravity center -extent 300x300 \
    +dither -quantize transparent -colors 64 \
    -unique-colors txt:- 2>/dev/null \
    | grep -oP '#[0-9A-Fa-f]{6}' \
    | tr '[:lower:]' '[:upper:]'
