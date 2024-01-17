class Admin::GenresController < Admin::BaseController
  include Admin::GenresConcern

  before_action :get_genre, only: %i(show edit update destroy)

  def index; end

  def show
    load_books
    @tab_id = :genre_books
    render "admin/shared/tab_books"
  end

  def new
    @genre = Genre.new
    render :edit
  end

  def edit; end

  def create
    @genre = Genre.new genre_params
    admin_save @genre, :genre
  end

  def update
    admin_update @genre, genre_params, :genre
  end

  def destroy
    admin_destroy @genre, :genre
  end

  private

  def get_genre
    @genre = Genre.find_by id: params[:id]
    return if @genre

    flash[:error] = t "admin.notif.item_not_found", name: t("genres._name")
    redirect_to admin_genres_path
  end
end
