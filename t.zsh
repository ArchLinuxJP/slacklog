#!/bin/zsh
d=${0:a:h}/json
team=archlinuxjp
repo=slacklog
general=C0GFH3RHC
random=C0GFH3RHU
now=`date '+%Y%m01'`
date=20191201
#date=20201201
limit=200

if [ -f ./config.json ];then
 token=`cat ./config.json|jq -r ".SLACK_TOKEN"`
fi

test_time(){
	file=$d/20210101_general.json
	if [ ! -f $file ];then
		exit
	fi
	t=`cat $file |jq -r ".messages|.[].ts"`
	n=`echo "$t"|wc -l`
	for ((i=1;i<=$n;i++))
	do
		o=`echo "$t"|awk "NR==$i"|cut -d . -f 1`
		echo $o
		date -r "$o" +"%Y-%m-%d %H:%M:%S"
	done
}

user_json(){
	# https://api.slack.com/methods/users.list
	url=https://slack.com/api/users.list
	if [ ! -f $d/user.json ];then
 	curl -X GET -H 'Content-type: application/json' "$url?token=$token" >! $d/user.json
	fi
}

slack_history(){
	if [ ! -f $json.json ];then
	 curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$general&latest=$latest&oldest=$oldest&limit=$limit" |jq . >! $json.json
	fi

	# next-page
	# 応答には、値を含む最上位のresponse_metadata属性が含まれnext_cursorます。cursor後続のリクエストでこの値をパラメータとして使用することでlimit、仮想ページごとにコレクション ページをナビゲートできます。
	if [ -f $json.json ];then
		n=`cat $json.json|jq -r ".response_metadata.next_cursor"`
	fi
	if [ "$n" != "null" ];then
		i=2
		while : 
		do
		jsons=$json-$i
		if [ ! -f $jsons.json ];then
		 curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$general&latest=$latest&oldest=$oldest&limit=$limit&cursor=$n" |jq . >! $jsons.json
		fi
		if [ -f $jsons.json ];then
			n=`cat $jsons.json|jq -r ".response_metadata.next_cursor"`
		fi
		if [ "$n" = "null" ]; then
			break
		fi
		((i++))
	done
	fi
	unset n
	unset i
}

slack_log(){
while :
do
	# https://api.slack.com/methods/conversations.history
	url=https://slack.com/api/conversations.history
	oldest=`date -j -f "%Y%m%d" "$date" +%s`
	latest=`date -j -v+1m -f "%Y%m%d" "$date" +%s`
	date=`date -r $latest +"%Y%m01"`
	date_o=`date -r $oldest +"%Y%m01"`

	json=$d/${date_o}_general
	slack_history

	json=$d/${date_o}_random
	slack_history

 if [ "$now" = "$date" ]; then
  break
 fi
done
}

user_json
slack_log
