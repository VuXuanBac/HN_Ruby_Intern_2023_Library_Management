class API::V1::Admin::BaseController < API::ApplicationController
  before_action :require_admin!

  protected

  def response_for_action action, result, object, name
    if result
      json_response object
    else
      json_errors object, I18n.t("api.#{action}_fail",
                                 name: I18n.t("#{name}s._name"))
    end
  end

  private

  def require_admin!
    return if @current_account.is_admin?

    json_message :no_permission, status: :unauthorized
  end
end
