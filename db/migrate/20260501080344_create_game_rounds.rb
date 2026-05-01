class CreateGameRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :game_rounds do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :score, null: false
      t.integer :hit, null: false, default: 0
      t.float :range
      t.timestamps
    end
  end
end
