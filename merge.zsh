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
old=`cat user.json|jq length`

if [ $new -gt $old ];then
 new=$(($new - 1))
 rm user.json
 unset body
 echo "[" >> user.json
 for (( i=0;i<=$new;i++ ))
 do
	cat user.json.tmp|jq -r ".members|.[$i]|.id"
	id=`cat user.json.tmp|jq -r ".members|.[$i]|.id"`
	img=`cat user.json.tmp|jq -r ".members|.[$i]|.profile.image_24"`
	name=`cat user.json.tmp|jq -r ".members|.[$i]|.name"`
	body=${body}"{\"id\":\"$id\",\"img\":\"$img\",\"name\":\"$name\"}",
 done
 body=${body}"{\"id\":\"$id\",\"img\":\"$img\",\"name\":\"$name\"}]"
 jq . <<< $body > user.json
fi

new=`cat $json| jq -r ".messages|.[0]|select(.client_msg_id !=null)|.client_msg_id"`
old=`cat $out| jq -r ".messages|.[0]|select(.client_msg_id !=null)|.client_msg_id"`
if [ "$new" = "$old" ];then
 exit
fi

#page
check=`cat $json| jq -r ".messages|.[]|select(.client_msg_id !=null)|select(.client_msg_id ==\"$old\")|.client_msg_id"`
if [ -z "$check" ];then
 echo over page
 rm $json
 url=https://slack.com/api/conversations.history
 curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$channel&limit=$page" |jq . > $json
fi

jq -s '.[0] * .[0]' $json $json.old > $json.tmp
mv $json.tmp $out
cp -rf $out $tmp_json

# apiで持ってきたjsonをそのまま使用することはできない
# usernameがidなので書き換える必要があるのとアイコンの要素を追加しないといけない
# これらもjqで可能だけどかなり面倒な処理が必要になる
# apiからもっと詳細なデータを要求することで解決できるとは思うけど、現在使用しているchannnel.historyの権限は割と低めで、public projectでは最も適切だと思う
