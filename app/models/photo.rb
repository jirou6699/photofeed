class Photo < ApplicationRecord
  belongs_to :user
  has_one_attached :thumbnail

  validates :title, presence: true, length: { maximum: 30 }
  validates :image, presence: true
end
