class API::V1::Admin::PublishersController < API::V1::Admin::BaseController
  include Admin::PublishersConcern

  before_action :get_publisher, only: %i(show update destroy books)

  def index
    json_response @publishers
  end

  def show
    json_response @publisher
  end

  def create
    @publisher = Publisher.new publisher_params
    ret = @publisher.save
    response_for_action :create, ret, @publisher, :publisher
  end

  def update
    ret = @publisher.update publisher_params
    response_for_action :update, ret, @publisher, :publisher
  end

  def destroy
    ret = @publisher.destroy
    response_for_action :delete, ret, @publisher, :publisher
  end

  def books
    load_books
    json_response @books, each_serializer: BookBasicSerializer
  end

  private

  def get_publisher
    @publisher = Publisher.find_by! id: params[:id]
  end
end
