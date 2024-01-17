class Admin::BooksController < Admin::BaseController
  include Admin::BooksConcern

  before_action :get_book,
                only: %i(show edit update destroy amend_edit amend)

  def index; end

  def show
    @tab_id = :book_detail
    render :tab_detail
  end

  def new
    @book = Book.new
    render :edit
  end

  def edit; end

  def create
    @book = Book.new book_params
    admin_save @book, :book,
               success_to: :amend_admin_book_path
  end

  def update
    return redirect_to amend_admin_book_path(@book) if params[:skip].present?

    admin_update @book, book_params, :book,
                 success_to: :amend_admin_book_path
  end

  def amend_edit; end

  def amend
    return redirect_to admin_book_path(@book) if params[:skip].present?

    p = relation_params
    ret = @book.update_relation p[:publisher],
                                p[:authors],
                                p[:genres]

    if ret
      flash[:success] = t "admin.notif.update_success", name: t("books._name")
      redirect_to [:admin, @book]
    else
      respond_to_form_fail @book
    end
  end

  def destroy
    if @book.borrowed_count.positive?
      flash.now[:error] = t "admin.notif.delete_book_fail_borrowed"
      return application_notify
    end
    destroy_method = @book.delete_temporarily
    admin_destroy @book, :book, destroy_method:
  end

  private

  def get_book
    @book = Book.find_by id: params[:id]

    return if @book&.is_active

    return if action_name == "show" && @book

    flash[:error] = t "admin.notif.item_not_found", name: t("books._name")
    redirect_to admin_books_path
  end
end
