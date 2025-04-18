class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true
end
