class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  belongs_to :user, if: :include_user?

  def include_user?
    @instance_options.fetch(:include_user, true)
  end
end
