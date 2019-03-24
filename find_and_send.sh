#!/bin/bash

FOLDER='test_folder'
EXTENSION='*.txt'

rm -f html.mail

echo "
From:$(whoami)@$(hostname)
To:soymatiasbarrios@gmail.com
Subject: IMPORTANT! Keywords matched at $(date)" >> html.mail

all_files=$( find $FOLDER -type f -name "$EXTENSION" -printf "'%p'\n"  2>/dev/null )



for filename in $all_files
do
    {  
        grep "$filename" sent_items.txt &>/dev/null \
        || for word in $( cat keywords.txt | tr '\n' ' ' )
        do
            grep "$word" $filename 1>/dev/null && {
                echo "$filename"
            }
        done
    } &
done

wait
