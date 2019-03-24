#!/bin/bash

FOLDER='test_folder'
EXTENSION='*.txt'

rm -f mail.html

echo "
From:$(whoami)@$(hostname)
To:soymatiasbarrios@gmail.com
Subject: IMPORTANT! Keywords matched at $(date)
MIME-Version: 1.0
Content-Type: text/html

<html>
<body>
<table style=\"border-style:solid;border-color:BLACK;border-size: 1px 2px 3px 5px;\">
<thead style=\"background-color:#2f97c4;border-style:solid; font-color:WHITE;\" >
<tr>
<th>
Keyword
</th>
<th>
Subject
</th>
<th>
Date
</th>
</tr>" >> mail.html

all_files=$( find $FOLDER -type f -name "$EXTENSION" -printf "%p\n"  2>/dev/null )

found=0

while read filename 
do
    {  
        grep "$filename" sent_items.txt &>/dev/null \
        || for word in $( cat keywords.txt | tr '\n' ' ' )
        do
            grep "$word" "$filename" &>/dev/null && {
                found=1
                keyword="$word"
                subject=$( grep '^Subject' "$filename" | awk -F'Subject:' '{ print $2}' )
                date=$( grep '^Date' "$filename" | awk -F'Date:' '{ print $2}' )
                echo "
                <tr>
                    <td>
                        $keyword
                    </td>
                    <td>
                        $subject
                    </td>
                    <td>
                        $date
                    </td>
                </tr>
                " >> mail.html
            }
        done
    } &
done <<< "$all_files"
 
wait

echo "
</table>
</body>
</html>
" >> mail.html

[[ $found -eq 1 ]] && /usr/sbin/sendmail -t soymatiasbarrios@gmail.com < mail.html

