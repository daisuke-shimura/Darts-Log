class GamesController < ApplicationController
  def index
  end

  def create
    options = 0

    options |= Game::Options::SEPARATE_BULL if params[:separate_bull] == "1"
    options |= Game::Options::MASTER_OUT if params[:master_out] == "1"

    game = Game.create!(
      user_id: current_user.id,
      kind: params[:kind],
      start_score: params[:start_score],
      options: options
    )

    if game.kind == "zero_one"
      redirect_to game_zero_one_path(game.id)
    elsif game.kind == "cricket"
      redirect_to game_cricket_path(game.id)
    elsif game.kind == "count_up"
      redirect_to game_count_up_path(game.id)
    elsif game.kind == "center_count_up"
      redirect_to game_center_count_up_path(game.id)
    elsif game.kind == "cricket_count_up"
      redirect_to game_cricket_count_up_path(game.id)
    elsif game.kind == "shoot_out"
      redirect_to game_shoot_out_path(game.id)
    end
  end

  # リザルト画面
  def show
    @game = Game.includes(:game_rounds).find(params[:id])
    @rounds = @game.game_rounds
  
    @total_sbull = @rounds.sum(:s_bull)
    @total_dbull = @rounds.sum(:d_bull)
  
    @bull_count = @total_sbull + @total_dbull
  
    @mark_count = @rounds.sum(:mark)
    @hit_count  = @rounds.sum(:hit)

    if @game.kind == "cricket_count_up"
      @round_marks = []
      @rounds.each_with_index do |round, i|
        round_mark = []
        round.darts.each do |dart|
          if valid_segment?((i + 1), dart.segment)
            mark = mark_value(dart.multiplier)
          else
            mark = 0
          end
          round_mark << mark
        end
        @round_marks << round_mark
      end
    elsif @game.kind == "cricket"
      cricket_segments = [20, 19, 18, 17, 16, 15, 50]
      @current_segments_status = cricket_segments.index_with(0)
      @round_marks = []
      @rounds.each_with_index do |round, r|
        @round_marks[r] = []
        round.darts.each_with_index do |dart, n|
          if @current_segments_status.key?(dart.segment)
            marks = case dart.multiplier
                    when "triple" then 3
                    when "double" then 2
                    else 1
                    end
            current = @current_segments_status[dart.segment]
            if current + marks > 3
              marks = 3 - current
            end
            @current_segments_status[dart.segment] += marks
            @round_marks[r][n] = marks
          end
        end
      end
    end
  end

  private
  CRICKET_SEGMENTS = [20, 19, 18, 17, 16, 15, 50]

  def valid_segment?(round_number, segment)
    if round_number >= 1 && round_number <= 7
      segment == CRICKET_SEGMENTS[round_number - 1]
    elsif round_number == 8
      CRICKET_SEGMENTS.include?(segment)
    else
      false
    end
  end

  def mark_value(multiplier)
    if multiplier == "triple"
      mark = 3
    elsif multiplier == "double"
      mark = 2
    elsif multiplier == "single"
      mark = 1
    else
      mark = 0
    end
    return mark
  end
end
