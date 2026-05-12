class AddRangeToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :range, :float
  end
end
