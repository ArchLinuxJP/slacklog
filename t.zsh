#!/bin/zsh
team=archlinuxjp
repo=slacklog
date=`date +"%Y%m"`
if [ -f ./config.json ];then
 token=`cat ./config.json|jq -r ".SLACK_TOKEN"`
else
 token=${SLACK_TOKEN}
fi
if [ -n "${WORKFLOW_FILE_PATH}" ];then
 wfile=${{ github.workflow }}         
else
 wfile=.github/workflow/random.yml
fi
wfile=${wfile##*/}
wfile=${wfile%%.*}
json=${wfile}.json
tmp_json=`echo $wfile|cut -b 1-3`.json
out=$date-$json
page=800
echo $wfile

url=https://slack.com/api/conversations.list
if [ ! -f ./list.json ];then
 curl -X GET -H "Authorization: Bearer $token" -H 'Content-type: application/json' $url > list.json
fi

general=`cat list.json| jq -r ".channels|.[0].id"`
random=`cat list.json| jq -r ".channels|.[1].id"`

if [ "$json" = "general.json" ];then
 channel=$general
else
 channel=`cat list.json| jq -r ".channels|.[]|select(.name == \"$wfile\")|.id"`
fi
echo $channel
#https://archlinuxjp.slack.com/archives/C0GFH3RHU/p1597982196026500
url_archive=https://archlinuxjp.slack.com/archives/$channel

url=https://slack.com/api/conversations.history
if [ ! -f ./$json ];then
 curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$channel&limit=100" |jq . > $json
fi

url=https://slack.com/api/users.list

if [ ! -f user.json.tmp ];then
 curl -X GET -H 'Content-type: application/json' "$url?token=$token" > user.json.tmp
fi
new=`cat user.json.tmp| jq -r ".members|length"`
new=$(($new - 1))

if [ -f user.json.t ];then
 rm user.json.t
fi
if [ ! -f user.json ];then
 for (( i=0;i<=$new;i++ ))
 do
	cat user.json.tmp|jq -r ".members|.[$i]|.id"
	id=`cat user.json.tmp|jq -r ".members|.[$i]|.id"`
	img=`cat user.json.tmp|jq -r ".members|.[$i]|.profile.image_24"`
	name=`cat user.json.tmp|jq -r ".members|.[$i]|.name"`
	echo "{\"id\":\"$id\",\"img\":\"$img\",\"name\":\"$name\"}" >> user.json.t
 done
 cat user.json.t|jq -s ".|= .+[]" > user.json
fi
old=`cat user.json|jq length`

if [ -f user.json.t ];then
 rm user.json.t
fi
if [ $new -gt $old ];then
 rm user.json
 for (( i=0;i<=$new;i++ ))
 do
	cat user.json.tmp|jq -r ".members|.[$i]|.id"
	id=`cat user.json.tmp|jq -r ".members|.[$i]|.id"`
	img=`cat user.json.tmp|jq -r ".members|.[$i]|.profile.image_24"`
	name=`cat user.json.tmp|jq -r ".members|.[$i]|.name"`
	echo "{\"id\":\"$id\",\"img\":\"$img\",\"name\":\"$name\"}" >> user.json.t
 done
 cat user.json.t|jq -s ".|= .+[]" > user.json
fi

#n=`cat $json| jq ".messages|length"`
cid=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|.client_msg_id"`
n=`echo "$cid"|wc -l|tr -d ' '`

if [ ! -f ./$out ];then
 for (( i=1;i<=$n;i++ ))
 do
	client_msg_id=`echo "$cid"|awk "NR==$i"`
	text=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|select(.client_msg_id == \"$client_msg_id\")|.text"`
	user=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|select(.client_msg_id == \"$client_msg_id\")|.user"|head -n 1`
	ts=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|select(.client_msg_id ==\"$client_msg_id\")|.ts"|head -n 1`
	if [ -n "$ts" ];then
	 stime=`echo $ts|cut -d . -f 1`
	 if [ -z "`echo $OSTYPE |grep darwin`" ];then
		stime=`date -d "@${stime}" +"%Y/%m/%d,%T"`
	 else
		stime=`date -r "${stime}" +"%Y/%m/%d,%T"`
	 fi
	 slink=`echo $ts|tr -d .`
	 slink="$url_archive/p${slink}"
	else
	 unset slink stime
	fi
	name=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.name"`
	img=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.img"`
	if jq -n --arg text "$text" "{\"user\":\"$user\",\"text\":\$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\",\"time\":\"$stime\",\"link\":\"$slink\"}";then
	 jq -n --arg text "$text" "{\"user\":\"$user\",\"text\":\$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\",\"time\":\"$stime\",\"link\":\"$slink\"}" >> $out
	fi
 done
 cat $out|jq -s ".|= .+[]" > $out.tmp
 mv $out.tmp $out
fi

cp -rf $out $tmp_json

tt=`cat $out| jq -r ".[0].client_msg_id"`
ttt=`echo "$cid"|head -n 1`
if [ "$tt" = "$ttt" ];then
 echo no new message
 exit
fi

#page
check=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|select(.client_msg_id ==\"$tt\")|.client_msg_id"`
if [ -z "$check" ];then
 echo over page
 rm $json
 url=https://slack.com/api/conversations.history
 curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$channel&limit=$page" |jq . > $json
 cid=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|.client_msg_id"`
fi

if [ -f ./cid.txt ];then
 rm ./cid.txt
fi

echo "$cid" > cid.txt
nh=`grep -n $tt cid.txt|cut -d : -f 1`

if [ -f ./$out.tmp ];then
 rm ./$out.tmp
fi
for (( i=1;i<=$nh;i++ ))
do
 client_msg_id=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|.client_msg_id"|awk "NR==$i"`
 echo $i $client_msg_id
 text=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|select(.client_msg_id ==\"$client_msg_id\")|.text"`
 user=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|select(.client_msg_id ==\"$client_msg_id\")|.user"|head -n 1`
 ts=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|select(.client_msg_id ==\"$client_msg_id\")|.ts"|head -n 1`
 stime=`echo $ts|cut -d . -f 1`
 if [ -z "`echo $OSTYPE |grep darwin`" ];then
	stime=`date -d "@${stime}" +"%Y/%m/%d %T" -d "9 hour"`
 else
	stime=`date -r "${stime}" +"%Y/%m/%d %T"`
 fi
 slink=`echo $ts|tr -d .`
 slink="$url_archive/p${slink}"
 name=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.name"`
 img=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.img"`
 if jq -n --arg text "$text" "{\"user\":\"$user\",\"text\":\$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\",\"time\":\"$stime\",\"link\":\"$slink\"}";then
	jq -n --arg text "$text" "{\"user\":\"$user\",\"text\":\$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\",\"time\":\"$stime\",\"link\":\"$slink\"}" >> $out.tmp
 fi
done

cido=`cat $out|jq -r ".[]|select(.client_msg_id !=null)|.client_msg_id"`
n=`echo "$cido"|wc -l |tr -d ' '`
for (( i=1;i<=$n;i++ ))
do
 client_msg_id=`cat $out|jq -r ".[$i]|.client_msg_id"`
 text=`cat $out|jq -r ".[$i]|.text"`
 user=`cat $out|jq -r ".[$i]|.user"`
 stime=`cat $out|jq -r ".[$i]|.time"`
 slink=`cat $out|jq -r ".[$i]|.link"`
 name=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.name"`
 img=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.img"`
 if jq -n --arg text "$text" "{\"user\":\"$user\",\"text\":\$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\",\"time\":\"$stime\",\"link\":\"$slink\"}" && [ "null" != "$user" ];then
	jq -n --arg text "$text" "{\"user\":\"$user\",\"text\":\$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\",\"time\":\"$stime\",\"link\":\"$slink\"}" >> $out.tmp
 fi
done
rm $out
cat $out.tmp|jq -s ".|= .+[]" > $out

#text : @${user} -> @${name}
t=`cat $out|grep '<*>'|grep '@'|tr '<' '\n' |grep '@'|cut -d '@' -f 2 |cut -d ">" -f 1|sort|uniq`
n=`echo "$t"|wc -l|tr -d ' '`
for ((i=1;i<=$n;i++))
do
 user=`echo "$t"|awk "NR==$i"`
 name=`cat user.json | jq -r ".[]|select(.id == \"$user\")|.name"`
 if [ -n "$name" ];then
	echo ${user} ${name}
	if [ -z "`echo $OSTYPE |grep darwin`" ];then
	 sed -i "s/<@${user}>/@${name}/g" $out
	else
	 sed -i "" "s/<@${user}>/@${name}/g" $out
	fi
 fi
done
cat $out|jq .

cp -rf $out $tmp_json
