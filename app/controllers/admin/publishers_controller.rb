class Admin::PublishersController < Admin::BaseController
  include Admin::PublishersConcern

  before_action :get_publisher, only: %i(show edit update destroy)

  def index; end

  def show
    load_books
    @tab_id = :publisher_books
    render "admin/shared/tab_books"
  end

  def new
    @publisher = Publisher.new
    render :edit
  end

  def edit; end

  def create
    @publisher = Publisher.new publisher_params
    admin_save @publisher, :publisher
  end

  def update
    admin_update @publisher, publisher_params, :publisher
  end

  def destroy
    admin_destroy @publisher, :publisher
  end

  private

  def get_publisher
    @publisher = Publisher.find_by id: params[:id]
    return if @publisher

    flash[:error] = t "admin.notif.item_not_found", name: t("publishers._name")
    redirect_to admin_publishers_path
  end
end
