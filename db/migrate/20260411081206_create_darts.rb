class CreateDarts < ActiveRecord::Migration[7.0]
  def change
    create_table :darts do |t|
      t.references :round, null: false, foreign_key: true
      t.integer :segment, null: false
      t.integer :multiplier, null: false
      t.integer :number, null: false
      t.integer :absolute_r
      t.integer :absolute_0
      t.integer :relative_x
      t.integer :relative_y
      t.timestamps
    end
  end
end
