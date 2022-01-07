class Hisseki < ApplicationRecord
  mount_uploader :image, HissekiUploader
  belongs_to :user
  validate :hisseki_size
  validate :writing_behavior_array
  validates :image, presence: true
  validates :writing_behavior, presence: true

  def hisseki_size
    @minimagick_image = MiniMagick::Image.open(Rails.root.join("public#{image}"))
    errors.add(:base, "画像のサイズが異なります") unless (@minimagick_image.type == "PNG") && (@minimagick_image.dimensions == [128, 128])
  end

  def writing_behavior_array
    errors.add(:writing_behavior, "描画時の挙動が送信されていません") unless writing_behavior =~ /^\[[0-9,]+\]$/
  end
end
