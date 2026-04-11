class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :gender
      t.date :birthday
      t.string :experience
      t.timestamps
    end
  end
end
