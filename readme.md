## slacklog

slackのlogを保存するproject

https://archlinuxjp.github.io/slacklog

- slack : https://archlinuxjp.slack.com

- 以前のslacklog : https://slack.archlinux.jp/log/2016/12/general/

- 2019-12-01からlogが生成されていない

- 2020-04-01からのlogは取得できた[2022-08-01]

### 削除依頼

例えば、機密情報を間違って投稿してしまったなど削除依頼があれば対応します。

slackからでもgithubからでもいいのでご連絡ください。

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

- [conversations.history](https://api.slack.com/methods/conversations.history)

- [user.list](https://api.slack.com/methods/users.list)

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

$ mv dist ../
$ git checkout gh-pages
$ cp -rf ../dist/{*.js,*.map} .
$ git add *.js *.map
$ git commit -m "deploy pages"
$ git push origin gh-pages
```

gh-pagesは基本的にvueで構築しています。

このrepoに置かれたjson-rawから取得表示します。

取得する期間はformに入力する形式に変更しました。

### update

主な更新履歴

#### v1.0

tag:v1.0では高頻度でjsonを更新していました。

新しい投稿があると、その月のjsonに追記する方式でjson自体も独自形成したものを生成していました。gh-pagesも新しいページを月単位で作成して追加していました。

開発者ポリシーの記述から論争が起きているのを見て、一時期停止していました。

#### v2.0

tag:v2.0では月1の取得に切り替えました。

できる限りslackからdownloadできるjsonをそのまま使うように変更しました。ただし、usernameだけはidからnameに置換しています。gh-pagesは完全に1ページのみにし、フォームからの入力を受けて表示コンテンツを切り替える方式に変更しました。

slackが90日以前の履歴を削除する方針を決定したタイミングでv2.0への移行を進めました。

