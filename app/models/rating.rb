class Rating < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :value, presence: true,
                    numericality: {
                      only_integer: true,
                      greater_than_or_equal_to: 1,
                      less_than_or_equal_to: 5
                    }

  validates :user_id, uniqueness: { scope: :post_id, message: "can only rate a post once" }

  def self.average_rating(post_id)
    post = Post.find(post_id)
    post.ratings.average(:value)
  end
end
