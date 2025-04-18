class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true

  scope :with_average_rating, -> {
    left_joins(:ratings)
      .select("posts.*, AVG(ratings.value) AS average_rating")
      .group("posts.id")
  }

  def self.top_rated(limit = 5)
    with_average_rating.order("average_rating DESC NULLS LAST").limit(limit)
  end
end
