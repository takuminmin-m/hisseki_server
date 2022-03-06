class UserSessionsController < ApplicationController
  def new; end

  def create
    @hisseki = Hisseki.new(hisseki_params)
    p "here"

    user_name = CertificationHissekiJob.perform_now(@hisseki)&.name

    p user_name

    @user = login(user_name, "password")

    json_return = if @user
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

    render json: json_return
  end

  def destroy
    return redirect_to new_hisseki_url, notice: "筆跡を10枚以上登録してください", status: :see_other if current_user.hissekis.count < 10
    logout
    redirect_to root_path, notice: "ログアウトしました", status: :see_other
  end
end
