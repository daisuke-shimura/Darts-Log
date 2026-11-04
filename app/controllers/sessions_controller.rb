class SessionsController < ApplicationController
  def create
    session[:user_id] = params[:user_id]
    session[:condition] = params[:condition]
    redirect_to root_path, notice: "ログインしました"
  end

  def destroy
    session.delete(:user_id)
    session.delete(:condition)
    redirect_to root_path, alert: "ログアウトしました"
  end
end
