# frozen_string_literal: true

module Participants
  class WithdrawnProfileFinder
    class << self
      def find(trn:, email:, type:)
        new(trn:, email:, type:).find
      end
    end

    VALID_TYPES = %i[ect mentor].freeze

    attr_reader :trn, :email, :type

    def initialize(trn:, email:, type:)
      @trn = trn
      @email = email
      @type = type
      raise ArgumentError, "type must be one of: #{VALID_TYPES.join(',')}" unless VALID_TYPES.include?(@type)
    end

    def find
      all.first
    end

  private

    def filter_to_type(scope)
      case type
      when :ect
        scope.ects
      when :mentor
        scope.mentors
      end
    end

    def all
      existing_withdrawn_record_by_trn(trn) ||
        existing_withdrawn_record_by_email(email) ||
        ParticipantProfile.none
    end

    def existing_withdrawn_record_by_trn(trn)
      lookup_trn = TeacherReferenceNumber.new(trn).formatted_trn
      teacher_profile = TeacherProfile.find_by(trn: lookup_trn)
      withdrawn_records = teacher_profile&.participant_profiles&.withdrawn_record
      filter_to_type(withdrawn_records) if withdrawn_records.present?
    end

    def existing_withdrawn_record_by_email(email)
      user = Identity.find_user_by(email:)
      withdrawn_records = user&.participant_profiles&.withdrawn_record
      filter_to_type(withdrawn_records) if withdrawn_records.present?
    end
  end
end
