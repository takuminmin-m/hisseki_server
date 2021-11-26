FactoryBot.define do
  factory :hisseki do
    image {Rack::Test::UploadedFile.new(File.join(Rails.root, "spec/fixtures/hisseki_test.png"))}
    user_id {1}
  end
end
