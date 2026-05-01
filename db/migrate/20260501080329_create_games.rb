class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :number, null: false
      t.float :stats, null: false
      t.integer :turn_number, null: false
      t.integer :type, null: false
      t.timestamps
    end
  end
end
