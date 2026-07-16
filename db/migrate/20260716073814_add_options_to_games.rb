class AddOptionsToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :options, :integer, default: 0, null: false
  end
end
