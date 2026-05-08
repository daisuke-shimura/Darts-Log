class AddRangeToRecordRounds < ActiveRecord::Migration[7.0]
  def change
    add_column :record_rounds, :score, :integer
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

    add_column :record_rounds, :gravity_center_x, :float
    add_column :record_rounds, :gravity_center_y, :float
    add_column :record_rounds, :gravity_distance_ave, :float
    add_column :record_rounds, :gravity_distance_max, :float
    add_column :record_rounds, :distance_ave, :float
    add_column :record_rounds, :variance, :float
    add_column :record_rounds, :variance_x, :float
    add_column :record_rounds, :variance_y, :float
    add_column :record_rounds, :area, :float
    add_column :record_rounds, :circle_center_x, :float
    add_column :record_rounds, :circle_center_y, :float
    add_column :record_rounds, :circle_radius, :float
  end
end
