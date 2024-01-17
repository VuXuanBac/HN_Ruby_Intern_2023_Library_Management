module Admin::GenresConcern
  extend ActiveSupport::Concern

  included do
    before_action :transform_params, only: :index
    before_action :populate_genres, only: :index
  end

  def index; end

  private

  def genre_params
    params.require(:genre).permit :name, :description
  end

  def transform_params
    permit_sorts = {
      name: "genres.name"
    }
    s = params[:sort]&.downcase&.to_sym
    params[:sort] = permit_sorts[s]
  end

  def populate_genres
    genres = Genre.all

    q = params[:q]
    genres = genres.bquery(q) if q

    s = params[:sort]
    genres = s ? genres.sort_on(s, params[:desc]) : genres.newest

    @pagy, @genres = pagy genres
  end

  def load_books
    @pagy, @books = pagy @genre.books.newest.with_attached_image
  end
end
