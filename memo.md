## キャッシュのON/OFF
`bin/rails dev:cache`

## キャッシュのリセット
`bin/rails tmp:cache:clear`

## 計測用DBの起動
`RAILS_ENV=production rails s -p 3001`
ポート番号を開発->3000 計測->3001に分けると分かりやすい
### JS/CSSを変更後実行
`RAILS_ENV=production rails assets:precompile`