class Hisseki < ApplicationRecord
  mount_uploader :image, HissekiUploader
  belongs_to :user
end
