class CreateGameRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :game_rounds do |t|

      t.timestamps
    end
  end
end
