require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /" do
    it "rootのリクエストにhomeを返す" do
      get "/"
      expect(response).to have_http_status(200)
      expect(response.body).to match("筆跡をパスワード代わりに使うアプリ")
    end
  end
end
