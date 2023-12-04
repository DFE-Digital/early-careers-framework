# frozen_string_literal: true

module NPQ
  class DedupeParticipant
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :npq_application
    attribute :trn

    validates :npq_application, presence: true
    validates :trn, presence: true
    validates :to_user, :from_user, presence: true
    validate :trn_validated
    validate :dedupe_already_taken

    def call
      return if invalid?

      Identity::Transfer.call(from_user:, to_user:)
    end

  private

    def from_user
      @from_user ||= participant_profile&.user
    end

    def to_user
      return if participant_profile&.teacher_profile.blank?

      @to_user ||= TeacherProfile
        .oldest_first
        .where(trn:)
        .where.not(id: participant_profile.teacher_profile.id)
        .first
        &.user
    end

    def participant_profile
      @participant_profile ||= ParticipantProfile.find_by(id: npq_application.id)
    end

    def trn_validated
      return if npq_application.teacher_reference_number_verified?

      errors.add(:trn, I18n.t(:trn_not_validated))
    end

    def dedupe_already_taken
      return if from_user&.participant_id_changes.blank?
      return unless from_user.participant_id_changes.where(from_participant: [from_user, to_user], to_participant: [from_user, to_user]).any?

      errors.add(:trn, I18n.t(:dedupe_has_already_taken_place))
    end
  end
end
