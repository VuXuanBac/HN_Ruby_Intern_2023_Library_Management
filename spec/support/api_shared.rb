require "rails_helper"

RSpec.shared_context "shared api" do
  let(:json_body){JSON.parse(response.body)}
  let(:account) do |ex|
    create(ex.metadata[:api_admin] ? :admin : :account)
  end

  before do |ex|
    unless ex.metadata[:no_token]
      account.renew_api_token unless account.api_token
      request.headers.merge!({"Authorization": "Bearer #{account.api_token}"})
    end
  end
end

RSpec.configure do |config|
  config.include_context "shared api", :api, :api_admin
end


RSpec.shared_examples "json status" do |status|
  it "responses with :#{status} status code" do
    expect(response).to have_http_status status
  end
end

RSpec.shared_examples "json message" do |message, status: :bad_request|
  include_examples "json status", status
  it "returns json message :#{message}" do
    expect(json_body["message"]).to eq I18n.t("api.#{message}")
  end
end

RSpec.shared_examples "json object" do |name, status: :ok|
  include_examples "json status", status

  it "returns :#{name} object with proper keys" do
    expect(json_body.keys).to include *serialize_attributes
  end
end

RSpec.shared_examples "json collection" do |name, size, status: :ok|
  include_examples "json status", status

  it "returns :#{name} array with proper size" do
    expect(json_body.length).to match size
  end

  it "returns :#{name} array with proper keys" do
    expect(json_body[0].keys).to include *serialize_attributes
  end
end

RSpec.shared_examples "json errors" do |name, action, status: :unprocessable_entity|
  include_examples "json status", status

  it "returns :#{action}_fail message for notification" do
    expect(json_body["message"]).to eq I18n.t("api.#{action}_fail", name: I18n.t("#{name}s._name"))
  end

  it "returns errors array for detailed" do
    expect(json_body["errors"]).to match assigns(name).errors.full_messages
  end
end

RSpec.shared_examples "API_CRUD" do |name|
  let(name){create(name)}
  let("#{name}_params"){attributes_for(name)}

  shared_examples "populate #{name}" do
    it "assigns the requested #{name} to @#{name}" do
      expect(assigns(name)).to eq send(name)
    end
  end

  describe "GET #index" do
    before do
      create_list(name, 3)
      get :index
    end

    include_examples "json collection", name, 3
  end

  describe "GET #show" do
    context "when #{name} is not found" do
      before do
        get :show, params: {id: -1}
      end
      include_examples "json message", :record_not_found, status: :not_found
    end

    context "when #{name} is found" do
      before do
        get :show, params: {id: send(name).id}
      end

      include_examples "json object", name
    end
  end

  describe "GET #books" do
    let("#{name}_with_books"){create(name, books: create_list(:book, 3))}
    let(:serialize_attributes){%w(id title description isbn amount available borrowed publish_date last_update cover)}

    before do
      get :books, params: {id: send("#{name}_with_books").id}
    end

    include_examples "json collection", :book, 3
  end

  describe "POST #create" do
    context "when params are valid" do
      before do
        post :create, params: {name => send("#{name}_params")}
      end

      it "saves the #{name} to database" do
        expect(assigns(name)).to be_persisted
      end

      include_examples "json object", name
    end

    context "when params are not valid" do
      before do |ex|
        post :create, params: {
          name => send("#{name}_params").merge({name: nil})
        }
      end

      include_examples "json errors", name, :create
    end
  end

  describe "PATCH #update" do
    before do
      patch :update, params: {id: send(name).id, name => send("#{name}_params")}
    end

    context "when params are valid" do
      it "changes the #{name} attributes" do
        expect(assigns(name).reload.attributes).to include(send("#{name}_params").transform_keys(&:to_s))
      end

      include_examples "json object", name
    end
  end

  describe "DELETE #destroy" do
    before do
      delete :destroy, params: {id: send(name).id, format: :turbo_stream}
    end

    context "when destroy successfully" do
      include_examples "json object", name
    end
  end
end
