require 'rails_helper'

RSpec.describe User, type: :model do
  describe "create" do
    it "Userを生成できる" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "passwordが存在しないと生成できない" do
      user = build(:user, password: "")
      user.valid?
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "nameがないと生成できない" do
      user = build(:user, name: "")
      user.valid?
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "nameが重複すると生成できない" do
      create(:user)
      user = build(:user)
      user.valid?
      expect(user.errors[:name]).to include("has already been taken")
    end
  end
end
