#!/bin/bash
# If an argument is provided, use it as location.
# Otherwise, fetch current location.
if [ -z "$1" ]; then
    LOC=$(curl -s ipinfo.io/loc)
    LAT=${LOC#*,}
    LON=${LOC%,*}
else
    # Geocode city name
    QUERY=$(echo "$1" | sed 's/ /+/g')
    # Use Nominatim API
    RESPONSE=$(curl -s -H "User-Agent: Gemini-CLI-Satellite-Widget" "https://nominatim.openstreetmap.org/search?q=$QUERY&format=json&limit=1")
    LAT=$(echo "$RESPONSE" | jq -r '.[0].lat')
    LON=$(echo "$RESPONSE" | jq -r '.[0].lon')
fi

# Yandex maps expect LON, LAT for ll parameter
curl -s -o /tmp/satellite.png "https://static-maps.yandex.ru/1.x/?ll=$LON,$LAT&size=450,450&z=13&l=sat"
