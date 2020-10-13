#!/bin/bash 

##################################################################################################
#

# Display stash details with colorized output.

#

# Author: Chr. Dek.

#

# Run this *.sh file from any git repo to display all stashes/details with weight-coloring-format

# 1-5 changes     (blue)

# 5-15 changes    (bright blue)

# 15-30 changes   (green)

# 30-45 changes   (bright yellow)

# 45-60 changes   (yellow)

# 60-80 changes   (light red)

# 80+ changes (red)

##################################################################################################

strong="$(tput bold)"; 
dim="$(tput dim)";
ul=`tput smul`  
rescol=`tput sgr0`

echo "${ul}${strong}STASH LIST:${rescol}" 
echo ""
git stash list >> ~/Desktop/out.txt 
sed -E 's/(:){1}[[:print:]]+//' < ~/Desktop/out.txt > ~/Desktop/st-out.txt ; rm ~/Desktop/out.txt 
while read line
do
stashout=`echo $line`
execstash="$(git stash show ${stashout})"
changenum=`echo ${execstash} | grep "changed, " | sed -e "s/[^0-9|^,]//g" -e "s/,/\n/g" | sed '2q;d'`

echo ${strong}"STASH NUM - ${stashout}"
if [[ "$changenum" -ge 1 ]] && [[ "$changenum" -le 5 ]] ; then
	echo ${execstash} | sed -e $'s/\(changed\, \)/\033[0;44m/' -e "s/\( \)/$rescol\1/"
fi

if [[ "$changenum" -ge 5 ]] && [[ "$changenum" -le 15 ]] ; then
	echo ${execstash} | sed -e $'s/\(changed\, \)/\033[0;104m/' -e "s/\( \)/$rescol\1/"
fi

if [[ "$changenum" -ge 15 ]] && [[ "$changenum" -le 30 ]] ; then
	echo ${execstash} | sed -e $'s/\(changed\, \)/\033[0;42m/' -e "s/\( \)/$rescol\1/"
fi

if [[ "$changenum" -ge 30 ]] && [[ "$changenum" -le 45 ]] ; then
	echo ${execstash} | sed -e $'s/\(changed\, \)/\033[0;103m/' -e "s/\( \)/$rescol\1/"
fi

if [[ "$changenum" -ge 45 ]] && [[ "$changenum" -le 60 ]] ; then
	echo ${execstash} | sed -e $'s/\(changed\, \)/\033[0;43m/' -e "s/\( \)/$rescol\1/"
fi

if [[ "$changenum" -ge 60 ]] && [[ "$changenum" -le 80 ]] ; then
	echo ${execstash} | sed -e $'s/\(changed\, \)/\033[0;101m/' -e "s/\( \)/$rescol\1/"
fi

if [[ "$changenum" -ge 80 ]] ; then
	echo ${execstash} | sed -e $'s/\(changed\, \)/\033[0;41m/' -e "s/\( \)/$rescol\1/"
fi

#echo ${execstash} | sed -e "s/\(changed\, \)/$setcolor\1/" -e "s/\( \)/$rescol\1/"
echo ${rescol}
done < ~/Desktop/st-out.txt

echo ${rescol}
rm ~/Desktop/st-out.txt

