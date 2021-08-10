class ApplicationController < ActionController::Base

  private

  def hisseki_params
    all_params = params.permit(:image_data_uri)
    all_params[:user_id] = session[:user_id]
    all_params
  end

  protected

  def not_authenticated
    redirect_to login_url, alert: "It's necessary to login."
  end
end
