class UsersController < ApplicationController
  before_action :set_user, only: :destroy
  before_action :require_login, only: :destroy

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_back_or_to root_url, notice: "ユーザーの作成に成功しました"
    else
      flash.now[:alert] = 'ユーザーの作成に失敗しました'
      render :new
    end
  end

  def index
    @users = User.all
  end

  def destroy
    @user.destroy
    redirect_to root_url
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    all_params = params.require(:user).permit(:name)
    all_params[:password] = "password"
    all_params
  end
end
