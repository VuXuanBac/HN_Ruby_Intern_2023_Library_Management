module Admin::UsersConcern
  extend ActiveSupport::Concern

  included do
    before_action :transform_params, only: :index
    before_action :populate_users, only: :index
  end

  def index; end

  private

  def transform_params
    permit_sorts = {
      username: "accounts.username",
      name: "user_infos.name",
      phone: "user_infos.phone",
      dob: "user_infos.dob",
      join: "user_infos.created_at"
    }
    s = params[:sort]&.downcase&.to_sym
    params[:sort] = permit_sorts[s]
    params[:desc] = !params[:desc] if %i(join).include? s
  end

  def populate_users
    users = Account.exclude(@current_account).only_activated.includes_info

    q = params[:q]
    users = users.merge(Account.bquery(q)) if q

    s = params[:sort]
    users = s ? users.sort_on(s, params[:desc]) : users.newest

    @pagy, @users = pagy users
  end

  def notify_user_when_inactive reason
    @user.send_inactive_email reason
    @user.notification_for_me :notice, "notifications.account_inactive"
  end
end
