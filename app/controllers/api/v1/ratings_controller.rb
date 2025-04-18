module Api::V1
  class RatingsController < ApplicationController
    before_action :set_post_and_user, only: [ :create ]

    def create
      RatePostJob.perform_later(@post.id, @user.id, rating_params[:value])
      render_accepted_response
    rescue StandardError => e
      handle_create_error(e)
    end

    private

    def rating_params
      params.permit(:post_id, :user_id, :value)
    end

    def set_post_and_user
      @post = Post.find(params[:post_id])
      @user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render_not_found(e.message)
    end

    def render_not_found(message)
      render json: { errors: [ message ] }, status: :not_found
    end

    def render_accepted_response
      render json: { average_rating: @post.average_rating }, status: :accepted
    end

    def render_unprocessable_entity(message)
      render json: { errors: [ message ] }, status: :unprocessable_entity
    end

    def render_internal_server_error
      render json: { errors: [ "Internal server error" ] }, status: :internal_server_error
    end

    def handle_create_error(error)
      case error
      when ArgumentError
        render_unprocessable_entity(error.message)
      when StandardError
        render_internal_server_error
      end
    end
  end
end
