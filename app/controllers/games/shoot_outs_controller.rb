class Games::ShootOutsController < ApplicationController
  def new
  end

  def show
    @game = Game.find(params[:game_id])
    @default_target = "bull"
    @default_target_name = "BULL"
    @segment_index = [20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5]
    @rate = 1
    # 続きから
    shoot_segments = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,50]
    @rounds = @game.game_rounds.includes(:darts).order(:created_at)
    @round_number = @rounds.count + 1
    @current_score = @rounds.sum(&:score)
    @current_segments_status = shoot_segments.index_with(0)
    @rounds.each_with_index do |round|
      round.darts.each_with_index do |dart, n|
        if @current_segments_status[dart.segment] == 0
          @current_segments_status[dart.segment] = dart.segment * dart.multiplier_before_type_cast * @rate
          @rate += 1
        end
      end
    end
  end

  def create
  end
end
