class AddRangeToRecordRounds < ActiveRecord::Migration[7.0]
  def change
    add_column :record_rounds, :hit, :integer, null: false, default: 0
    add_column :record_rounds, :range, :float
  end
end
