class Admin::UsersController < Admin::BaseController
  include Admin::UsersConcern

  before_action :get_user, only: %i(show active inactive)

  def index; end

  def show
    @tab_id = :user_profile
    render :tab_profile
  end

  def active
    respond_to_change_active true
  end

  def inactive
    reason = params[:reason]
    if reason.blank?
      flash.now[:warning] = t "admin.notif.require_lock_reason"
      application_notify
    else
      return unless respond_to_change_active false

      notify_user_when_inactive reason
    end
  end

  private

  def get_user
    @user = Account.find_by id: params[:id]
    return if @user&.is_activated

    flash[:error] = t("admin.notif.item_not_found", name: t("accounts._name"))
    redirect_to admin_users_path
  end

  def respond_to_change_active is_active
    is_success = @user.change_is_active_to is_active

    result = is_success ? :success : :error
    key = "#{is_active ? :active : :inactive}_user_success"
    key = "update_user_status_error" unless is_success

    respond_to do |format|
      format.turbo_stream do
        flash.now[result] = t("admin.notif.#{key}")
        render :change_status
      end
      format.html do
        flash[result] = t("admin.notif.#{key}")
        redirect_to admin_users_path
      end
    end
    is_success
  end
end
