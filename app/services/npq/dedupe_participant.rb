# frozen_string_literal: true

module NPQ
  class DedupeParticipant
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :npq_application
    attribute :trn

    validates :npq_application, presence: { message: I18n.t(:missing_npq_application) }
    validates :trn, presence: { message: I18n.t(:missing_trn) }
    validates :to_user, presence: { message: I18n.t(:missing_to_user) }
    validates :from_user, presence: { message: I18n.t(:missing_from_user) }
    validate :trn_validated
    validate :dedupe_already_taken

    def call
      return if invalid?

      Identity::Transfer.call(from_user:, to_user:)
    end

  private

    def from_user
      @from_user ||= User.find_by(id: npq_application&.user_id)
    end

    def to_user
      @to_user ||= TeacherProfile
        .joins(:user)
        .includes(:user)
        .oldest_first
        .where(trn:)
        .where.not(users: { id: from_user&.id })
        .first
        &.user
    end

    def trn_validated
      return if npq_application&.teacher_reference_number_verified?

      errors.add(:trn, I18n.t(:trn_not_validated))
    end

    def dedupe_already_taken
      return if from_user&.participant_id_changes.blank?
      return unless from_user.participant_id_changes.where(from_participant: [from_user, to_user], to_participant: [from_user, to_user]).any?

      errors.add(:trn, I18n.t(:dedupe_has_already_taken_place))
    end
  end
end
