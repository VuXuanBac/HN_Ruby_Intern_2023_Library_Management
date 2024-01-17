class BookBasicSerializer < ApplicationSerializer
  attributes :title, :description, :publish_date, :isbn

  attribute :amount, if: :admin_only
  attribute :borrowed_count, key: :borrowed, if: :admin_only
  attribute :is_active, key: :available

  has_one :image, key: :cover do |serializer|
    serializer.link_for_attachment :image
  end
end
