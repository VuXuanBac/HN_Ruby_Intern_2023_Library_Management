class API::V1::Admin::BooksController < API::V1::Admin::BaseController
  include Admin::BooksConcern

  before_action :get_book, only: %i(show update destroy amend)

  def index
    json_response @books
  end

  def show
    json_response @book
  end

  def create
    @book = Book.new book_params
    ret = @book.save
    response_for_action :create, ret, @book, :book
  end

  def update
    ret = @book.update book_params
    response_for_action :update, ret, @book, :book
  end

  def amend
    p = relation_params
    ret = @book.update_relation p[:publisher],
                                p[:authors],
                                p[:genres]

    response_for_action :update, ret, @book, :book
  end

  def destroy
    if @book.borrowed_count.positive?
      json_message :delete_book_fail_borrowed
    else
      ret = @book.delete_temporarily
      response_for_action :delete, ret, @book, :book
    end
  end

  private

  def get_book
    @book = Book.find_by! id: params[:id]

    return unless action_name != "show" && !@book&.is_active

    raise ActiveRecord::RecordNotFound
  end
end
