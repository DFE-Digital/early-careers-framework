# frozen_string_literal: true

module NPQ
  class DedupeParticipant
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :npq_application
    attribute :trn

    validates :trn, presence: true
    validates :npq_application, presence: true
    validate :trn_validated

    def call
      return if invalid?

      if get_an_identity_id_clash?
        # If both users have a get_an_identity_id, we transfer to the most recent
        from_user, to_user = users.sort_by(&:updated_at)
      else
        from_user, to_user = users
      end

      Identity::Transfer.call(from_user:, to_user:)
    end

  private

    def users
      [npq_application.user, primary_user_for_trn]
    end

    def primary_user_for_trn
      Identity::PrimaryUser.find_by(trn:)
    end

    def get_an_identity_id_clash?
      users.all? { |user| user.get_an_identity_id.present? }
    end

    def trn_validated
      errors.add(:trn, I18n.t(:trn_not_validated)) unless npq_application&.teacher_reference_number_verified?
    end
  end
end
