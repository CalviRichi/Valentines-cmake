#!/bin/zsh

for f in game_over meow_1 meow_2 meow_3 meow_4; do
    ffmpeg -y -i "$f.mp3" -acodec pcm_s16le "${f}_fixed.wav"
    mv "${f}_fixed.wav" "$f.wav"
done
