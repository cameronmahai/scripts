#!/bin/bash
# Fetch location
LOC=$(curl -s ipinfo.io/loc)
LAT=${LOC#*,}
LON=${LOC%,*}
# Fetch image
curl -s -o /tmp/satellite.png "https://static-maps.yandex.ru/1.x/?ll=$LAT,$LON&size=450,450&z=13&l=sat"
