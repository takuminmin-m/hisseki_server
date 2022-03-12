class ApplicationController < ActionController::Base

  private

  def hisseki_params
    params.permit(:image_data_uri, :writing_behavior)
  end

  def model_date
    hisseki_csv_path = Rails.root.join("ml/hisseki_list.csv")

    # hisseki_list.csvが生成されていないときのエラー回避
    return Time.new(2020) unless File.exist?(hisseki_csv_path)

    File.open(hisseki_csv_path, "r") do |f|
      return f.atime
    end
  end

  protected

  def not_authenticated
    redirect_to login_url, alert: "ログインが必要です"
  end
end
