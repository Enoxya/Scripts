for i in test.txt
do
   iconv -f utf8 -t iso8859-15 "$i" > "$i"2.new
done