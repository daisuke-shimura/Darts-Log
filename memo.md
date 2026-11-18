## キャッシュのON/OFF
`bin/rails dev:cache`

## キャッシュのリセット
`bin/rails tmp:cache:clear`

## 計測用DBの起動
`RAILS_ENV=production rails s -p 3001`
ポート番号を開発->3000 計測->3001に分けると分かりやすい
### 起動中に別ターミナルでログを見る
`tail -f log/production.log`

### JS/CSSを変更後実行 (リロードしてもCSS反映されない！)
`RAILS_ENV=production rails assets:precompile`
### 開発環境に設定を戻す (assetsを削除)
`rails assets:clobber`
### db編集後
`RAILS_ENV=production rails db:migrate`

## バックアップをDropBoxに作成
`./backup_db.sh`

### 権限を復活
`chmod +x script.sh`

## CSV出力
```ruby
require "csv"

bull_darts = Dart.where.not(record_round_id: nil)
                 .where(target: "bull")

date = Time.current.strftime("%Y%m%d")

CSV.open("exports/bull_darts_#{date}.csv", "w") do |csv|
  csv << [
    "id",
    "segment",
    "multiplier",
    "number",
    "absolute_r",
    "absolute_0",
    "x",
    "y",
    "target",
    "created_at"
  ]

  bull_darts.select(
    :id,
    :segment,
    :multiplier,
    :number,
    :absolute_r,
    :absolute_0,
    :x,
    :y,
    :target,
    :created_at
  ).find_each do |dart|
    csv << [
      dart.id,
      dart.segment,
      dart.multiplier,
      dart.number,
      dart.absolute_r,
      dart.absolute_0,
      dart.x,
      dart.y,
      dart.target,
      dart.created_at
    ]
  end
end

puts "CSV出力が完了しました！"
```

```ruby
darts = Dart.joins(:record_round)
            .where(target: "bull")
            .where(record_rounds: { user_id: 5 })

require "csv"

record_rounds = RecordRound.where(user_id: 5)

date = Time.current.strftime("%Y%m%d")

CSV.open("exports/record_rounds_#{date}.csv", "w") do |csv|
  csv << [
    "id",
    "user_id",
    "created_at",
    "condition"
  ]

  record_rounds.find_each do |record_round|
    csv << [
      record_round.id,
      record_round.user_id,
      record_round.created_at,
      record_round.condition
    ]
  end
end

puts "CSV出力が完了しました！"
```
