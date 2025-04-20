class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true

  scope :top_rated, -> {
    select("posts.*, AVG(ratings.value) as average_rating")
      .joins(:ratings)
      .group("posts.id")
      .order("average_rating DESC")
  }

  def average_rating
    ratings.average(:value).to_f
  end

  def self.grouped_ips_with_logins
    joins(:user)
      .group(:ip)
      .pluck(:ip, Arel.sql("ARRAY_AGG(users.login)"))
      .map { |ip, logins| { ip: ip, logins: logins.uniq } }
  end
end
