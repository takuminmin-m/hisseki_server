class ApplicationController < ActionController::Base

  private
  
  def hisseki_params
    params.permit(:image_data_uri)
  end

  protected

  def not_authenticated
    redirect_to login_url, alert: "It's necessary to login."
  end
end
