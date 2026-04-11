class SessionsController < ApplicationController
  def create
    session[:user_id] = params[:user_id]
    redirect_to records_path, notice: "ログインしました"
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "ログアウトしました"
  end
end
