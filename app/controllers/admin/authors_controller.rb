class Admin::AuthorsController < Admin::BaseController
  include Admin::AuthorsConcern

  before_action :get_author, only: %i(show edit update destroy)

  def index; end

  def show
    load_books
    @tab_id = :author_books
    render "admin/shared/tab_books"
  end

  def new
    @author = Author.new
    render :edit
  end

  def edit; end

  def create
    @author = Author.new author_params
    admin_save @author, :author
  end

  def update
    admin_update @author, author_params, :author
  end

  def destroy
    admin_destroy @author, :author
  end

  private

  def get_author
    @author = Author.find_by id: params[:id]
    return if @author

    flash[:error] = t "admin.notif.item_not_found", name: t("authors._name")
    redirect_to admin_authors_path
  end
end
