#!/bin/zsh
set -e
d=${0:a:h}
t=`zsh -c "ls $d/.github/workflows|grep -v gh-pages.yml"`
for ((i=1;i<=`echo $t|wc -l`;i++ ))
do
	tt=$d/.github/workflows/`echo "$t"|awk "NR==$i"`
	echo $tt
	cat $d/yml/1.yml >! $tt
	cat $d/t.zsh | sed -e '1d' -e "s/^/        /g" >> $tt
	cat $d/yml/2.yml >> $tt
done
