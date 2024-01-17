require "support/api_shared"

RSpec.describe API::V1::Admin::PublishersController, :api_admin, type: :controller do
  let(:serialize_attributes){%w(id name email address about last_update)}
  include_examples "API_CRUD", :publisher
end
