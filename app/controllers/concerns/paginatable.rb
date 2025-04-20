module Paginatable
  extend ActiveSupport::Concern

  def paginate(collection)
    paginatable = collection.respond_to?(:page) ? collection : Kaminari.paginate_array(Array.wrap(collection))
    paginatable.page(params[:page].presence || 1).per(params[:per_page].presence || 10)
  end
end
