module Admin::AuthorsConcern
  extend ActiveSupport::Concern

  included do
    before_action :transform_params, only: :index
    before_action :populate_authors, only: :index
  end

  def index; end

  private

  def author_params
    params.require(:author).permit :name, :about, :phone,
                                   :email, :avatar
  end

  def transform_params
    permit_sorts = {
      name: "authors.name",
      email: "authors.email",
      phone: "authors.phone"
    }
    s = params[:sort]&.downcase&.to_sym
    params[:sort] = permit_sorts[s]
  end

  def populate_authors
    authors = Author.with_attached_avatar

    q = params[:q]
    authors = authors.bquery(q) if q

    s = params[:sort]
    authors = s ? authors.sort_on(s, params[:desc]) : authors.newest

    @pagy, @authors = pagy authors
  end

  def load_books
    @pagy, @books = pagy @author.books.newest.with_attached_image
  end
end
