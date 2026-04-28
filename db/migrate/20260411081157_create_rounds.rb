class CreateRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :rounds do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :number, null: false
      t.timestamps
    end
  end
end
