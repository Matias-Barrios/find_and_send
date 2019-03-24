#!/bin/bash

FOLDER='test_folder'
EXTENSION='*.txt'

rm -f mail.html found.txt
echo 0 > found.txt

echo "
From:$(whoami)@$(hostname)
To:soymatiasbarrios@gmail.com
Subject: IMPORTANT! Keywords matched at $(date)
MIME-Version: 1.0
Content-Type: text/html

<html>
<style>
thead,
tfoot {
    background-color: rgb(52, 96, 218);
    color: #fff;
}

tbody {
    background-color: #e4f0f5;
    border: 2px solid rgb(200, 200, 200);
}

th, td {
  border: 1px solid #bbb;
  padding: 2px 8px 0;
  text-align: left;
}

caption {
    padding: 10px;
    caption-side: bottom;
}

table {
    border-collapse: collapse;
    border: 2px solid rgb(200, 200, 200);
    letter-spacing: 1px;
    font-family: sans-serif;
    font-size: .8rem;
    width: 80%;
}
</style>
<body>

<p><b>Some keywords matched at $(date)</b></p>

<table>
<thead>
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
</tr>
</thead>
<tbody>" >> mail.html

all_files=$( find $FOLDER -type f -name "$EXTENSION" -printf "%p\n"  2>/dev/null )

while read filename 
do
    {  
        grep "$filename" sent_items.txt &>/dev/null \
        || for word in $( cat keywords.txt | tr '\n' ' ' )
        do
            
            grep "$word" "$filename" &>/dev/null && {
                echo "$filename" >> sent_items.txt
                echo 1 > found.txt
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
            }&
        done
    } 
done <<< "$all_files"
 
wait

echo "
</tbody>
</table>
</body>
</html>
" >> mail.html

sort sent_items.txt | uniq > tmp.txt && cat tmp.txt > sent_items.txt && rm -f tmp.txt

[[ "$( cat found.txt )" == "1" ]] && { 
    echo "Sending mail on $(date)...";
    /usr/sbin/sendmail -t soymatiasbarrios@gmail.com < mail.html;
    echo "Done";
    }

