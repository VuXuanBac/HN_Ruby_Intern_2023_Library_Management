class AccountBasicSerializer < ApplicationSerializer
  attributes :email, :username, :is_admin
  attributes :is_activated, :is_active
  attribute :created_at, key: :join_from

  has_one :avatar do |serializer|
    serializer.link_for_attachment :avatar
  end
end
