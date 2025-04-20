module Api::V1
  class PostsController < ApplicationController
    before_action :set_user, only: [ :create ]

    def create
      post = @user.posts.build(post_params)

      if post.save
        render json: post, status: :created
      else
        render_validation_errors(post)
      end
    end

    def top_rated
      posts = Post.top_rated(params[:limit] || 5)
      render json: posts, include_user: false, status: :ok
    end

    private

    def set_user
      @user = User.find_or_create_by!(login: params[:login])
    end

    def render_validation_errors(invalid_record)
      render json: { errors: invalid_record.errors.full_messages }, status: :unprocessable_entity
    end

    def post_params
      params.permit(:title, :body, :ip)
    end
  end
end
