class RatingSerializer < ActiveModel::Serializer
  attributes :id, :value
  belongs_to :post
  belongs_to :user
end
