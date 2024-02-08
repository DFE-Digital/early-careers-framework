# frozen_string_literal: true

module NPQ
  class DedupeParticipant
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :npq_application
    attribute :trn

    validates :npq_application, presence: { message: I18n.t(:missing_npq_application) }
    validates :trn, presence: { message: I18n.t(:missing_trn) }
    validates :primary_user_for_trn, presence: { message: I18n.t(:missing_primary_user_for_trn) }
    validates :application_user, presence: { message: I18n.t(:missing_application_user) }
    validate :trn_validated
    validate :duplication_exists

    def call
      return if invalid?

      Identity::Transfer.call(from_user: application_user, to_user: primary_user_for_trn)
    end

  private

    def application_user
      @application_user ||= User.find_by(id: npq_application&.user_id)
    end

    def primary_user_for_trn
      @primary_user_for_trn ||= TeacherProfile
        .joins(:user)
        .includes(:user)
        .oldest_first
        .where(trn:)
        .first
        &.user
    end

    def duplication_exists
      errors.add(:trn, I18n.t(:no_dedupe_required)) if primary_user_for_trn == application_user
    end

    def trn_validated
      errors.add(:trn, I18n.t(:trn_not_validated)) unless npq_application&.teacher_reference_number_verified?
    end
  end
end
