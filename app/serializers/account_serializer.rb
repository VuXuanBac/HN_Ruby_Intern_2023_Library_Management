class AccountSerializer < AccountBasicSerializer
  has_one :user_info, key: :bio
end
