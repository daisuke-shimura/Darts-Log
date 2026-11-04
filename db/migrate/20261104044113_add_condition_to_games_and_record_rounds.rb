class AddConditionToGamesAndRecordRounds < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :condition, :integer, default: 0, null: false
    add_column :record_rounds, :condition, :integer, default: 0, null: false
  end
end
