class API::V1::Admin::UsersController < API::V1::Admin::BaseController
  include Admin::UsersConcern

  before_action :get_user, only: %i(show active inactive)

  def index
    json_response @users
  end

  def show
    json_response @user
  end

  def active
    respond_to_change_active true
  end

  def inactive
    reason = params[:reason]
    return json_message :require_lock_reason if reason.blank?

    return unless respond_to_change_active false

    notify_user_when_inactive reason
  end

  private

  def get_user
    @user = Account.find_by! id: params[:id], is_activated: true
  end

  def respond_to_change_active is_active
    is_success = @user.change_is_active_to is_active

    status_code = is_success ? :ok : :bad_request
    key = "#{is_active ? :active : :inactive}_user_success"
    key = "update_user_status_error" unless is_success

    json_message key, status: status_code
    is_success
  end
end
