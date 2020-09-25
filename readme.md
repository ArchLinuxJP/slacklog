## slacklog

slackのlogを保存するproject

slack : https://archlinuxjp.slack.com

以前 : https://slack.archlinux.jp/log/2016/12/general/

### 削除依頼

例えば、機密情報を間違って投稿してしまったなど削除依頼があれば対応します。

slackからでもgithubからでもいいのでご連絡ください。

### 概要

gh-actionsで定期的にcronして、slack-apiの[conversations.history](https://api.slack.com/methods/conversations.history)を叩きます。token権限はchannel.historyを与えています。更新があれば、このリポジトリのjsonを更新します。

pushは[こちら](https://github.com/marketplace/actions/github-push)を利用します。

公開される情報を必要最小限にするためjsonは独自に形成したものを使用します。しかし、突貫工事で作ったためshellscriptとjqを利用しています。これは可読性に欠けるため、できればgoとかでそれぞれの処理を簡略化したほうがいいでしょう。

htmlは、gh-pagesとvueでjsonを参照します。

### 使い方

`t.zsh`でテストします。`./config.json`をおいてください。

`build.zsh`でgh-actionsのymlを作成します。内容はそのまま`t.zsh`のものになります。

actions内で作成されるファイルは、ymlのファイル名になります。

例えば、`random.yml`の場合は以下になります。

```sh
api : random.json

update : ran.json #最初の3文字

date : 202009-random.json
```

updateとdateは基本的に同じものになります。updateがlatestを意味し、channel-pageのトップに使われます。dateはCIを回した月を取得しますので、月が変わると、新しいjsonが作成され、pushされます。

actionsを作りたい場合は`.github/workflows`以下に取得したいchannel-nameのymlを作成し、`build.zsh`を実行すればOKです。例えば、`#example`なら`example.yml`になります。新しいchannelを作成した場合、`list.json`を削除しておいてください。slackの負担を軽減するために更新せず使用しています。

```sh
# example
# channel-name : example
$ touch .github/workflows/example.yml
$ ./build.zsh
```

ただし、channel-nameが3文字以下の場合は`t.zsh`の`tmp_json`を変更する必要があります。

```sh
#go
- tmp_json=`echo $wfile|cut -b 1-3`.json
+ tmp_json=`echo $wfile|cut -b 1`.json
```

### gh-pages

gh-pagesは基本的にvueで構築しています。新しい機能をテストするページは以下になります。

https://archlinuxjp.github.io/slacklog/random/202010/

#### その月に一致したものを表示する

現在、特定のディレクトリ(日付)で、その月に投稿されたもののみを表示する実装をテスト中。

currentdirと`value.time`の値の一致を見ます。

```html
<template v-if="value.time.split('/')[0] + value.time.split('/')[1] === dirname">
	<td><img v-bind:src="value.img"></td>
</template>
```

```js
computed: {
 dirname() {
	var currentUrl = window.location.pathname.split('/')[3];
	//var currentUrl = "202010";
	return currentUrl;
 }
}
```

#### markdownをhtmlに変換する(marked)

textが基本的にmd形式なので、それをhtmlに変換すると見栄えが良くなります。また、出力されるhtmlに対応した`syntax-highlight`をつけるといいかもしれません。

```html
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<div v-if="markdownText = value.text" v-html="compiledMarkdown"></div>
```

```js
data: {
 markdownText: ''
},
computed: {
 compiledMarkdown() {
  return marked(this.markdownText)
 }
}
```

#### markdownパーサの変遷(vue-markdown)

`marked.js`を使っていましたが、`vue-markdown`に切り替えました。

`backtick`がうまく変換されないことが多かった。ただし、現在も末尾がそのまま残ってしまっているので問題はあります。

https://github.com/miaolz123/vue-markdown

```html
<script src="./dist/vue-markdown.js"></script>
<vue-markdown>{{ value.text }}</vue-markdown>
<script>Vue.use(VueMarkdown);</script>
```

どうやら末尾のbacktickに直前改行がない場合は残ってしまうようです。

とりあえず以下の解決方法がありますが、推奨されません。

```html
<vue-markdown>{{ value.text.replace(/```/g,'\n```') }}</vue-markdown>
```


