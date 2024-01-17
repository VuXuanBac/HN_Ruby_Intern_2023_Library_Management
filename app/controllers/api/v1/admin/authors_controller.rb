class API::V1::Admin::AuthorsController < API::V1::Admin::BaseController
  include Admin::AuthorsConcern

  before_action :get_author, only: %i(show update destroy books)

  def index
    json_response @authors
  end

  def show
    json_response @author
  end

  def create
    @author = Author.new author_params
    ret = @author.save
    response_for_action :create, ret, @author, :author
  end

  def update
    ret = @author.update author_params
    response_for_action :update, ret, @author, :author
  end

  def destroy
    ret = @author.destroy
    response_for_action :delete, ret, @author, :author
  end

  def books
    load_books
    json_response @books, each_serializer: BookBasicSerializer
  end

  private

  def get_author
    @author = Author.find_by! id: params[:id]
  end
end
