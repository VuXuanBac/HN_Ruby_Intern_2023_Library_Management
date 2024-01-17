require "support/api_shared"

RSpec.describe API::V1::Admin::AuthorsController, :api_admin, type: :controller do
  let(:serialize_attributes){%w(id name email phone about last_update avatar)}
  include_examples "API_CRUD", :author
end
