class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :ip
end
