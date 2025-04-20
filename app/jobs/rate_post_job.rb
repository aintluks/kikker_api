class RatePostJob < ApplicationJob
  queue_as :default

  def perform(post, user, value)
    ActiveRecord::Base.transaction do
      post.with_lock do
        post.ratings.create!(user: user, value: value)
      end
    end
  rescue => e
    Rails.logger.error "Rating failed: #{e}"
    raise e
  end
end
