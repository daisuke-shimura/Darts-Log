class UpdateDartsRelations < ActiveRecord::Migration[7.0]
  def change
    remove_index :darts, name: "index_darts_on_round_id"

    rename_column :darts, :round_id, :record_round_id

    change_column_null :darts, :record_round_id, true

    add_column :darts, :game_round_id, :bigint

    add_index :darts, :record_round_id
    add_index :darts, :game_round_id

    add_check_constraint :darts,
      "(record_round_id IS NOT NULL AND game_round_id IS NULL) OR (record_round_id IS NULL AND game_round_id IS NOT NULL)",
      name: "check_darts_parent"
  end
end
