module Admin::PublishersConcern
  extend ActiveSupport::Concern

  included do
    before_action :transform_params, only: :index
    before_action :populate_publishers, only: :index
  end

  def index; end

  private

  def publisher_params
    params.require(:publisher).permit :name, :address, :about, :email
  end

  def transform_params
    permit_sorts = {
      name: "publishers.name",
      email: "publishers.email"
    }
    s = params[:sort]&.downcase&.to_sym
    params[:sort] = permit_sorts[s]
  end

  def populate_publishers
    publishers = Publisher.all

    q = params[:q]
    publishers = publishers.bquery(q) if q

    s = params[:sort]
    publishers = s ? publishers.sort_on(s, params[:desc]) : publishers.newest

    @pagy, @publishers = pagy publishers
  end

  def load_books
    @pagy, @books = pagy @publisher.books.newest.with_attached_image
  end
end
