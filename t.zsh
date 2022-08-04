#!/bin/zsh
team=archlinuxjp
repo=slacklog
general=C0GFH3RHC
random=C0GFH3RHU
now=`date '+%Y%m01'`
date=20191201
#date=20201201

if [ -f ./config.json ];then
 token=`cat ./config.json|jq -r ".SLACK_TOKEN"`
fi

test_time(){
	file=20210101_general.json
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
	url=https://slack.com/api/users.list
 curl -X GET -H 'Content-type: application/json' "$url?token=$token" >! user.json
}

slack_log(){
while :
do
	url=https://slack.com/api/conversations.history
	oldest=`date -j -f "%Y%m%d" "$date" +%s`
	latest=`date -j -v+1m -f "%Y%m%d" "$date" +%s`
	date=`date -r $latest +"%Y%m01"`
	date_o=`date -r $oldest +"%Y%m01"`

	json=${date_o}_general.json
	if [ ! -f ./$json ];then
	 curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$general&latest=$latest&oldest=$oldest&include_all_metadata=true" |jq . >! $json
	fi

	json=${date_o}_random.json
	if [ ! -f ./$json ];then
	 curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$random&latest=$latest&oldest=$oldest&include_all_metadata=true" |jq . >! $json
	fi

 if [ "$now" = "$date" ]; then
  break
 fi
done
}

#user_json
slack_log
