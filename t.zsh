#!/bin/zsh
team=syui
repo=slacklog
ACCESS_TOKEN=`cat ./config.json|jq -r ".ACCESS_TOKEN"`
token=`cat ./config.json|jq -r ".SLACK_TOKEN"`

url=https://slack.com/api/conversations.list
if [ ! -f ./list.json ];then
	curl -X GET -H "Authorization: Bearer $token" -H 'Content-type: application/json' $url > list.json
fi

general=`cat list.json| jq -r ".channels|.[0].id"`
randam=`cat list.json| jq -r ".channels|.[1].id"`

url=https://slack.com/api/conversations.history

if [ ! -f ./general.json ];then
	curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$general" > general.json
fi

if [ ! -f ./randam.json ];then
	curl -X GET -H 'Content-type: application/json' "$url?token=$token&channel=$randam" > randam.json
fi

url=https://slack.com/api/users.list

if [ ! -f user.json.tmp ];then
	curl -X GET -H 'Content-type: application/json' "$url?token=$token" > user.json.tmp
fi

new=`cat user.json.tmp| jq -r ".members|length"`
old=`cat user.json|jq length`

if [ $new -gt $old ];then
	new=`expr $new - 1`
	echo "[" >> user.json
	rm user.txt
	rm user.json
	for (( i=0;i<=$new;i++ ))
	do
		echo $i
		cat user.json.tmp|jq ".members|.[$i]|.id,.name,.profile.image_24"
		id=`cat user.json.tmp|jq -r ".members|.[$i]|.id"`
		img=`cat user.json.tmp|jq -r ".members|.[$i]|.profile.image_24"`
		name=`cat user.json.tmp|jq -r ".members|.[$i]|.name"`
		t=${img##*.}
		##download icon
		#if [ ! -d ./icon/$id ];then
		#	mkdir -p ./icon/$id
		#	curl -sL "$img" -o ./icon/$id/icon.$t
		#fi
		if [ $i -eq $new ];then
			echo "{\"id\":\"$id\",\"img\":\"$img\",\"name\":\"$name\"}" >> user.json
		else
			echo "{\"id\":\"$id\",\"img\":\"$img\",\"name\":\"$name\"}", >> user.json
		fi
	done
	echo $new > user.txt
	echo "]" >> user.json

	git clone https://github.com/$team/$repo
	cp -rf user.json $repo/
	cd $repo
  git config --local user.name "gh-actions"
  git config --local user.email "syui@users.noreply.github.com"
	git add user.json
	git commit -m "update user"
	git push https://x-access-token:${ACCESS_TOKEN}@github.com/$team/$repo master
	cd ..
fi

if [ -f t.json ];then
	rm t.json
fi

tt=`cat general.json| jq ".messages|.[0].client_msg_id"`
n=`cat gen.json| jq "length"`
echo "[" >> t.json
for (( i=0;i<=$n;i++ ))
do
	ttt=`cat gen.json| jq ".[$i].client_msg_id"`
	if [ "$tt" != "$ttt" ];then
		cat gen.json| jq ".[$i]|.client_msg_id,.text"
		client_msg_id=`cat gen.json| jq -r ".[$i]|.client_msg_id"`
		text=`cat gen.json| jq ".[$i]|.text"`
		user=`cat gen.json| jq -r ".[$i]|.user"`
		name=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.name"`
		img=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.img"`
		echo $name
		echo "{\"user\":\"$user\",\"text\":$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\"}", >> t.json
	else
		break
	fi
done

echo new ok
n=`cat general.json| jq ".messages|length"`
n=`expr $n - 1`
for (( i=0;i<=$n;i++ ))
do
	cat general.json| jq ".messages|.[$i]|.client_msg_id,.text"
	client_msg_id=`cat general.json| jq -r ".messages|.[$i]|.client_msg_id"`
	text=`cat general.json| jq ".messages|.[$i]|.text"`
	user=`cat general.json| jq -r ".messages|.[$i]|.user"`
	name=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.name"`
	img=`cat user.json|jq -r ".[]|select(.id == \"$user\")|.img"`
	echo $name
	if [ $i -eq $n ];then
		echo "{\"user\":\"$user\",\"text\":$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\"}" >> t.json
	else
		echo "{\"user\":\"$user\",\"text\":$text,\"client_msg_id\":\"$client_msg_id\",\"name\":\"$name\",\"img\":\"$img\"}", >> t.json
	fi
done

echo "]" >> t.json

cat t.json| tr -d '[:cntrl:]'|jq . > t.json.tmp
rm t.json
mv t.json.tmp gen.json

