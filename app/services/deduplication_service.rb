# frozen_string_literal: true

class DeduplicationService < ::BaseService
  def call
    select_users_to_archive.each(&:archive!)
  end

private

  def select_users_to_archive
    ids = User.left_joins(:participant_identities).where(participant_identities: { user_id: nil }).pluck(:id)

    ids_to_exclude = []
    ids_to_exclude << AdminProfile.where(user_id: ids).pluck(:user_id)
    ids_to_exclude << AppropriateBodyProfile.where(user_id: ids).pluck(:user_id)
    ids_to_exclude << DeliveryPartnerProfile.where(user_id: ids).pluck(:user_id)
    ids_to_exclude << FinanceProfile.where(user_id: ids).pluck(:user_id)
    ids_to_exclude << InductionCoordinatorProfile.where(user_id: ids).pluck(:user_id)
    ids_to_exclude << LeadProviderProfile.where(user_id: ids).pluck(:user_id)

    ids -= ids_to_exclude.flatten.uniq
    User.where(id: ids)
  end
end
