class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?
  before_action :set_today_data

  private
  def set_today_data
    return unless user_signed_in?
    @all_records   = current_user.record_rounds.count
    @all_games     = current_user.games.count
    @today_records = current_user.record_rounds.where(created_at: Time.current.all_day).count
    @today_games   = current_user.games.where(created_at: Time.current.all_day).count
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    redirect_to root_path, alert: "ログインしてください" unless user_signed_in?
  end
end
