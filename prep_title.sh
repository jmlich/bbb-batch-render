#!/bin/bash
#

#set -x

infile="template_1.svg"
infile2="template_2.svg"

#curl https://www.openalt.cz/form/program_prezentace2.php > prep_title.txt

found=0

while IFS=";" read cut_start cut_end video_in filename start end day speakers topic; do
#    echo "cut_start=$cut_start cut_end=$cut_end video_in=$video_in filename=$filename start=$start end=$end day=$day speakers=$speakers topic=$topic"

#    echo $filename
#    echo $speakers
#    echo $topic
    topic=${topic//\//\\\/}
    topic=${topic//&/\\&amp;}

    if [[ -n "$1" && "$filename" != "$1" ]]; then
        continue
    else
        found=$(( found + 1 ))
    fi

    tmp=$(mktemp /tmp/titulky.XXXXXX)
    tmp2=$(mktemp /tmp/titulky.XXXXXX)
    cat "$infile" | sed "s/%START%/$start/g" | sed "s/%END%/$end/g" |sed "s/%DAY%/$day/g"   | sed "s/%SPEAKERS%/$speakers/g"  | sed "s/%TOPIC%/$topic/g" > "$tmp"
    cat "$infile2" | sed "s/%START%/$start/g" | sed "s/%END%/$end/g" |sed "s/%DAY%/$day/g"   | sed "s/%SPEAKERS%/$speakers/g"  | sed "s/%TOPIC%/$topic/g" > "$tmp2"
    ret=$?
    if [ "$ret" -ne 0 ] ; then
        echo $filename
        exit 1
    fi

    rm -f "./output/$filename.png"
    rm -f "./output2/$filename.png"
#    inkscape -z --export-background-opacity=0 --export-height=1080 --export-type=pdf --export-filename="./output/$filename.pdf" "$tmp"
    inkscape -z --export-png="./output/$filename.png" "$tmp" &> /dev/null
    inkscape -z --export-png="./output2/$filename.png" "$tmp2" &> /dev/null
#    inkscape -z --export-background-opacity=0 --export-height=1080 --export-type=png --export-filename="./output/$filename.png" "$tmp" &> /dev/null
#    inkscape -z --export-background-opacity=0 --export-height=1080 --export-type=png --export-filename="./output2/$filename.png" "$tmp2" &> /dev/null
    ret=$?
    if [ "$ret" -ne 0 ] ; then
        echo "Error: inkscape cannot export $filename" >&2
        exit 1
    fi

#    ./png_to_mp4.sh "./output2/$filename.png" "./output2/$filename.mp4" &> /dev/null

    rm -f "$tmp"
    rm -f "$tmp2"

done < "video_cuts.txt"


if [ "$found" -eq 0 ]; then
    echo "not found $1" >&2
fi