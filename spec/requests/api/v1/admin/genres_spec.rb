require "support/api_shared"

RSpec.describe API::V1::Admin::GenresController, :api_admin, type: :controller do
  let(:serialize_attributes){%w(id name description last_update)}
  include_examples "API_CRUD", :genre
end
