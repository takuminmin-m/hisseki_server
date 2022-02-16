class UserSessionsController < ApplicationController
  def new; end

  def create
    p hisseki_params
    @hisseki = Hisseki.new(hisseki_params)
    unless @hisseki.valid?
      flash.now[:alert] = "認証に失敗しました"
      render create
      return
    end

    user_name = CertificationHissekiJob.perform_now(@hisseki)&.name

    p user_name

    @user = login(user_name, "password")

    if @user
      redirect_to root_url, notice: "認証に成功しました"
    else
      flash.now[:alert] = "認証に失敗しました"
      render create
    end
  end

  def destroy
    return redirect_to new_hisseki_url, notice: "筆跡を10枚以上登録してください" if current_user.hissekis.count < 10
    logout
    redirect_to root_path, notice: "ログアウトしました"
  end
end
