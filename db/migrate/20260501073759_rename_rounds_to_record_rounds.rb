class RenameRoundsToRecordRounds < ActiveRecord::Migration[7.0]
  def change
    rename_table :rounds, :record_rounds
  end
end
