class UserInfoSerializer < ApplicationSerializer
  attributes :gender, :address, :phone, :citizen_id, :dob
  attribute :name, key: :full_name
end
