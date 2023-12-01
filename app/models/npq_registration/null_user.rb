class NPQRegistration::NullUser < NPQRegistration::User
  def null_user?
    true
  end

  # Whether this user has admin access to the feature flagging interface
  def flipper_access?
    false
  end

  def flipper_id
    "User;#{feature_flag_id}"
  end

  attr_accessor :feature_flag_id
end
