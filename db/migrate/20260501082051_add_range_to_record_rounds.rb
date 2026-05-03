class AddRangeToRecordRounds < ActiveRecord::Migration[7.0]
  def change
    add_column :record_rounds, :hit, :integer, null: false, default: 0
    add_column :record_rounds, :range, :float
    add_column :record_rounds, :s_bull, :integer, null: false, default: 0
    add_column :record_rounds, :d_bull, :integer, null: false, default: 0
    add_column :record_rounds, :low_ton, :boolean, null: false, default: false
    add_column :record_rounds, :hat_trick, :boolean, null: false, default: false
    add_column :record_rounds, :three_in_a_bed, :boolean, null: false, default: false
    add_column :record_rounds, :high_ton, :boolean, null: false, default: false
    add_column :record_rounds, :ton80, :boolean, null: false, default: false
    add_column :record_rounds, :white_horse, :boolean, null: false, default: false
    add_column :record_rounds, :three_in_the_black, :boolean, null: false, default: false
    add_column :record_rounds, :bust, :boolean, null: false, default: false
  end
end
