class RatePostJob < ApplicationJob
  queue_as :default
  retry_on ActiveRecord::RecordNotUnique, attempts: 3

  def perform(post_id, user_id, value)
    post = Post.find(post_id)
    user = User.find(user_id)

    ActiveRecord::Base.transaction do
      post.with_lock do
        raise ActiveRecord::RecordInvalid if post.ratings.exists?(user_id: user_id)

        rating = post.ratings.create!(user: user, value: value)
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Rating failed: #{e.message}"
    raise
  end
end
