#!/usr/bin/env bash
# Warning, output is ~730M and takes about 16400s to generate

fonts="script lean slant shadow standard small smshadow mini banner"

echo "" > $1

for font in $fonts; do
  echo "Handling $font"
  cat /usr/share/dict/words | awk "/.*/ { print(\"-:\" \$0 \";$font>\"); system(\"figlet -f $font \" \$0 \" | wc -l\"); system(\"figlet -f $font \" \$0); }" >> $1
done
