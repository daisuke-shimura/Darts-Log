class CreateGameRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :game_rounds do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :score
      t.integer :hit, null: false, default: 0
      t.float :range
      t.integer :s_bull, null: false, default: 0
      t.integer :d_bull, null: false, default: 0
      t.boolean :low_ton, null: false, default: false
      t.boolean :hat_trick, null: false, default: false
      t.boolean :three_in_a_bed, null: false, default: false
      t.boolean :high_ton, null: false, default: false
      t.boolean :ton80, null: false, default: false
      t.boolean :white_horse, null: false, default: false
      t.boolean :three_in_the_black, null: false, default: false
      t.boolean :bust, null: false, default: false
      t.timestamps
    end
  end
end
