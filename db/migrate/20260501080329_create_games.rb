class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :number, null: false
      t.integer :kind, null: false
      t.integer :start_score
      t.float :stats
      t.integer :turn_number
      t.boolean :finished, null: false, default: false
      t.timestamps
    end
  end
end
