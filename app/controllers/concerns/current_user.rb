# frozen_string_literal: true

module CurrentUser
  # We can't use @current_user, as it is already used by the original method from Devise and is used by test helpers
  # rubocop:disable Naming/MemoizedInstanceVariableName
  def current_user
    return @deduped_current_user if defined? @deduped_current_user

    original = super
    return if original.nil?

    transferred_identity = ParticipantIdentity
      .where(external_identifier: original.id)
      .where.not(user_id: original.id)
      .first

    @deduped_current_user = transferred_identity&.user || original
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def impersonate_user(user)
    super
    remove_instance_variable(:@deduped_current_user)
  end

  def stop_impersonating_user
    super
    remove_instance_variable(:@deduped_current_user)
  end
end
