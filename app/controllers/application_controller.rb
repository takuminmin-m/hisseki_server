class ApplicationController < ActionController::Base

  private

  def hisseki_params
    params.permit(:image_data_uri, :writing_behavior)
  end

  protected

  def not_authenticated
    redirect_to login_url, alert: "ログインが必要です"
  end
end
