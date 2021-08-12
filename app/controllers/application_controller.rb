class ApplicationController < ActionController::Base

  protected

  def not_authenticated
    redirect_to login_url, alert: "It's necessary to login."
  end
end
