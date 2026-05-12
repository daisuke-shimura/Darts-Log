class CreateDarts < ActiveRecord::Migration[7.0]
  def change
    create_table :darts do |t|
      t.references :record_round, foreign_key: true
      t.references :game_round, foreign_key: true
      t.integer :segment, null: false
      t.integer :multiplier, null: false
      t.integer :number, null: false
      t.integer :absolute_r
      t.decimal :absolute_0, precision: 6, scale: 3
      t.integer :index_r
      t.integer :index_n
      t.integer :target
      t.boolean :bounce_out, null: false, default: false
      t.check_constraint(
        "(record_round_id IS NOT NULL AND game_round_id IS NULL) OR (record_round_id IS NULL AND game_round_id IS NOT NULL)",
        name: "check_darts_parent"
      )

      t.timestamps
    end
  end
end
