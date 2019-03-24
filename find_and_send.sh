#!/bin/bash

FOLDER='test_folder'
EXTENSION='*.txt'

rm -f html.mail

echo "
From:$(whoami)@$(hostname)
To:soymatiasbarrios@gmail.com
Subject: IMPORTANT! Keywords matched at $(date)
MIME-Version: 1.0
Content-Type: text/html

<html>
<body>
<table style=\"border-style:solid;border-color:BLUE;border-size: 1px 2px 3px 5px\">
<thead>
<tr>
<td>
Keyword
</td>
<td>
Subject
</td>
<td>
Date
</td>
</tr>" >> html.mail

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
                </tr>
                <tr>
                    <td>
                        $subject
                    </td>
                </tr>
                <tr>
                    <td>
                        $date
                    </td>
                </tr>
                " >> html.mail
            }
        done
    } &
done <<< "$all_files"
 
wait

echo "
</table>
</body>
</html>
" >> html.mail

[[ $found -eq 1 ]] && /usr/sbin/sendmail -t soymatiasbarrios@gmail.com < html.mail

