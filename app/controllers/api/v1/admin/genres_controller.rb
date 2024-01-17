class API::V1::Admin::GenresController < API::V1::Admin::BaseController
  include Admin::GenresConcern

  before_action :get_genre, only: %i(show update destroy books)

  def index
    json_response @genres
  end

  def show
    json_response @genre
  end

  def create
    @genre = Genre.new genre_params
    ret = @genre.save
    response_for_action :create, ret, @genre, :genre
  end

  def update
    ret = @genre.update genre_params
    response_for_action :update, ret, @genre, :genre
  end

  def destroy
    ret = @genre.destroy
    response_for_action :delete, ret, @genre, :genre
  end

  def books
    load_books
    json_response @books, each_serializer: BookBasicSerializer
  end

  private

  def get_genre
    @genre = Genre.find_by! id: params[:id]
  end
end
