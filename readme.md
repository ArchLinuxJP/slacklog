## slacklog

slackのlogを保存するproject

- slack : https://archlinuxjp.slack.com

- 以前のslacklog : https://slack.archlinux.jp/log/2016/12/general/

- 2019-12-01からlogが生成されていない

- 2020-04-01からのlogは取得できた[2022-08-01]

### 削除依頼

例えば、機密情報を間違って投稿してしまったなど削除依頼があれば対応します。

slackからでもgithubからでもいいのでご連絡ください。

### 概要

gh-actionsで定期的にcronして、slack-apiの[conversations.history](https://api.slack.com/methods/conversations.history)を叩きます。token権限はchannel.historyを与えています。更新があれば、このリポジトリのjsonを更新します。nameを取得するのに[user.list](https://api.slack.com/methods/users.list)も利用します。

pushは[こちら](https://github.com/marketplace/actions/github-push)を利用します。

公開される情報を必要最小限にするためjsonは独自に形成したものを使用します。しかし、突貫工事で作ったためshellscriptとjqを利用しています。これは可読性に欠けるため、できればgoとかでそれぞれの処理を簡略化したほうがいいでしょう。

htmlは、gh-pagesとvueでjsonを参照します。

### slack api

https://api.slack.com/apps : `slacklog`

`Basic Information > Add features and functionality > OAuth & Permissions`

> config.json

```json
{
 "SLACK_TOKEN":"xoxp-0000-0000-0000"
}
```

`User Token Scopes` : [channels:history](https://api.slack.com/scopes/channels:history), [users:read](https://api.slack.com/scopes/users:read)

### 使い方

```sh
$ echo "{\"SLACK_TOKEN\":\"xoxp-0000-0000-0000\"}" > config.json"
$ cat config.json
{
 "SLACK_TOKEN":"xoxp-0000-0000-0000"
}

$ ./linux.zsh
```

- `linux.zsh`で20191201からlog(conversations.history)を取得します。

- jsonはuserがidになっているため、`user.list`からnameを取得し、json:userを書き換えます。

- `json/latest.json`を生成し、最新の保存状況を伝えます。

### gh-pages

```sh
$ git checkout vue
$ yarn install
$ yarn serve
$ yarn build
$ ls dist/
```

gh-pagesは基本的にvueで構築しています。

このrepoに置かれたjson-rawから取得表示します。

取得する期間はformに入力する形式に変更しました。

