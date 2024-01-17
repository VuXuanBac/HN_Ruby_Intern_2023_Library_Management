class ApplicationSerializer < ActiveModel::Serializer
  attribute :updated_at, key: :last_update, if: :admin_only
  attribute :id

  def admin_only
    scope&.is_admin?
  end

  def link_for_attachment attribute_name
    object.send(attribute_name).url
  end
end
