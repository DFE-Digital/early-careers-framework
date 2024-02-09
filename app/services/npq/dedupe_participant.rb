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

      Identity::Transfer.call(from_user: npq_application.user, to_user: primary_user_for_trn)
    end

  private

    def primary_user_for_trn
      Identity::PrimaryUser.find_by(trn:)
    end

    def trn_validated
      errors.add(:trn, I18n.t(:trn_not_validated)) unless npq_application&.teacher_reference_number_verified?
    end
  end
end
