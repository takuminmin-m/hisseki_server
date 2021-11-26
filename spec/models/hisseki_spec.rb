require 'rails_helper'

RSpec.describe Hisseki, type: :model do
  describe "create" do
    it "Hissekiを生成できる" do
      create(:user, id: 1)
      hisseki = build(:hisseki)
      hisseki.valid?
      expect(hisseki).to be_valid
    end

    it "imageが存在しないと生成できない" do
      create(:user, id: 1)
      hisseki = build(:hisseki, image: nil)
      hisseki.valid?
      expect(hisseki.errors[:image]).to include("can't be blank")
    end

    it "user_idが存在しないと生成できない" do
      hisseki = build(:hisseki, user_id: nil)
      hisseki.valid?
      expect(hisseki.errors[:user_id]).to include("can't be blank")
    end

    it "関連付けられたuserが存在しないと生成できない" do
      hisseki = build(:hisseki)
      expect(hisseki.errors[:user_id]).to include("must exist")
    end
  end
end
