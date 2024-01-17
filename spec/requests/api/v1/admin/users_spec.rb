require "support/api_shared"

RSpec.describe API::V1::Admin::UsersController, :api_admin, type: :controller do
  let(:user){create(:account)}
  let(:serialize_attributes){%w(email username is_admin is_activated is_active join_from bio)}

  shared_examples "change status" do |action, more_params = {}|
    before do
      post action, params: {id: user.id}.merge(more_params)
    end

    context "when success" do
      let(:user) do
        (action == :active) ? create(:inactive_account) : create(:account)
      end

      it "changes user status" do
        expect(user.reload.is_active).to eq (action == :active)
      end

      include_examples "json message", "#{action}_user_success", status: :ok
    end

    context "when fail" do
      let(:user) do
        (action == :active) ? create(:account) : create(:inactive_account)
      end

      it "keeps user status" do
        expect(user.reload.is_active).to eq (action == :active)
      end

      include_examples "json message", :update_user_status_error
    end
  end

  describe "GET #index" do
    before do
      create_list(:user_info, 2)
      create_list(:not_activated_account, 2)
      get :index
    end

    include_examples "json collection", :user, 2
  end

  describe "GET #show" do
    context "when user id is not found" do
      before do
        get :show, params: {id: -1}
      end

      include_examples "json message", :record_not_found, status: :not_found
    end

    context "when user not activated" do
      before do
        get :show, params: {id: create(:not_activated_account).id}
      end

      include_examples "json message", :record_not_found, status: :not_found
    end

    context "when user is activated" do
      before do
        get :show, params: {id: user.id}
      end

      include_examples "json object", :user
    end
  end

  describe "POST #active" do
    include_examples "change status", :active
  end

  describe "POST #inactive" do
    context "with reason" do
      include_examples "change status", :inactive, {reason: "A Reason"}
    end

    context "without reason" do
      before do
        post :inactive, params: {id: user.id}
      end

      include_examples "json message", :require_lock_reason
    end
  end
end
