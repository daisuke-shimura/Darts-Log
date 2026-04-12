class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?
  before_action :clear_session

  private
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    redirect_to root_path, alert: "ログインしてください" unless user_signed_in?
  end

  def clear_session
    unless controller_name == "records"
      session.delete(:user_id)
    end
  end
end
