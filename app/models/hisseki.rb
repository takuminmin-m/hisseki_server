class Hisseki < ApplicationRecord
  mount_uploader :image, HissekiUploader
  belongs_to :user
  validate :hisseki_size
  validates :image, presence: true

  def hisseki_size
    @minimagick_image = MiniMagick::Image.open("public#{image}")
    errors.add(:base, "画像のサイズが異なります") unless (@minimagick_image.type == "PNG") && (@minimagick_image.dimensions == [128, 128])
  end
end
