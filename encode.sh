#!/bin/bash
ffmpeg -framerate 1 -pattern_type glob -i '*.jpg' -c:v libx264 -r 24 -t 5 -pix_fmt yuv420p out.mp4
