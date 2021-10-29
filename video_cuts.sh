#!/bin/bash

#set -x

DIR=$(pwd)

#
# @param $1 e.g. 00:00:12
# @return e.g.12

function time_to_seconds()
{
    if [[ "$1" =~ ^(([0-9]*):)?([0-9]+):([0-9]+)$ ]]; then
        h=${BASH_REMATCH[2]##0}
        m=${BASH_REMATCH[3]##0}
        s=${BASH_REMATCH[4]##0}
        sec=$(( h * 3600 + m * 60 + s ))
        echo "$sec"
    else
        echo "Error: cannot parse time \"$1\"" >&2
        exit 1
    fi
}


while IFS=";" read cut_start cut_end video_in filename start end day speakers topic; do
    echo "cut_start=$cut_start cut_end=$cut_end video_in=$video_in filename=$filename start=$start end=$end day=$day speakers=$speakers topic=$topic"

    if [ ! -d "$video_in" ]; then
        echo "Error: video_in for \"$filename\" doesn't exists" >&2;
        continue;
    fi


    if ! cut_start_s=$(time_to_seconds "$cut_start"); then
        echo "skipping $filename" >&2
        continue;
    fi
    if ! cut_end_s=$(time_to_seconds "$cut_end"); then
        echo "skipping $filename" >&2
        continue;
    fi

    if [[ -z "$1" && -f "./video_out/$filename.mp4" ]]; then
        echo "video $filename already exists";
        continue;
    fi

    ./prep_title.sh "$filename"

    ./bbb-render/make-xges.py --start $cut_start_s --end $cut_end_s --backdrop "./output/$filename.png"  "$video_in" "$DIR/tmp/$filename.xges" --prepend-file "$DIR/output2/$filename.png" "$DIR/1.png" --append-file "$DIR/2.png" "$DIR/3.png" "$DIR/4.png"
    rm -f "$DIR/video_out/$filename.mp4"
    ges-launch-1.0 --load "$DIR/tmp/$filename.xges" -o "$DIR/video_out/$filename.mp4"


done < "video_cuts.txt"


