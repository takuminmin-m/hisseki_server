class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :hissekis, dependent: :destroy_async

  validates :password, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :name, uniqueness: true
  validates :name, presence: true
end
