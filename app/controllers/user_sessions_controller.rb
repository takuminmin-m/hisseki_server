class UserSessionsController < ApplicationController
  def new
    @hisseki = Hisseki.new
  end

  def create
    @hisseki = Hisseki.new(hisseki_params)
    user_name = CertificationHissekiJob.perform_now(@hisseki.image.current_path)&.name

    p user_name

    unless user_name
      # js側でエラーメッセージを表示
      @json_return = {
        message: "faild to certificate",
        url: login_url
      }
      render json: @json_return
      return
    end

    @user = login(user_name, "password")

    @json_return = if @user
      {
        message: "認証に成功しました",
        url: root_url
      }
    else
      {
        message: "認証に失敗しました",
        url: login_url
      }
    end

    render json: @json_return
  end

  def destroy
    logout
    redirect_to root_path, notice: "ログアウトしました"
  end
end
