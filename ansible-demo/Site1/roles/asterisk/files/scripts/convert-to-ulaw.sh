#!/bin/bash

echo converting *.mp3 files to *.wav
for file in $1/*.mp3
do
	[ -e $file ] || continue	
	if [ ! -f ${file%.mp3}.wav ]; then
		echo converting $file to ${file%.mp3}.wav
		lame --decode $file ${file%.mp3}.wav
	fi
done

echo converting *.wav files to *.alaw *.gsm
for file in $1/*.wav
do
	[ -e $file ] || continue	
	if [ ! -f ${file%.wav}.alaw ]; then
			sox -V $file -r 8000 -c 1 -t al "${file%.wav}.alaw"
	fi
	if [ ! -f ${file%.wav}.gsm ]; then
			sox -V $file -r 8000 -c 1 -t gsm "${file%.wav}.gsm"
	fi
done

echo converting *.alaw files to *g729
for file in $1/*.alaw
do
	[ -e $file ] || continue	
	if [ ! -f ${file%.alaw}.g729 ]; then
		   asterisk -rx "file convert $file ${file%.alaw}.g729"
	fi
done