# frozen_string_literal: true

module Support
  module Participants
    module Mentors
      class Remove < Support::BaseService
        class << self
          def call(participant_profile_id:, school_urn:)
            new(participant_profile_id:, school_urn:).call
          end
        end

        attr_reader :participant_profile, :school, :school_mentor
        attr_writer :logger # allow logging to be disabled for specs

        def initialize(participant_profile_id:, school_urn:)
          @participant_profile = ParticipantProfile::Mentor.find(participant_profile_id)
          @school = School.find_by(urn: school_urn)

          unless participant_mentoring_at_school?
            log_error("ParticipantProfile is not a mentor at this school", raise: true)
          end
        end

        def call
          ActiveRecord::Base.transaction do
            log_message("Removing mentor from school")
            ::Mentors::RemoveFromSchool.call(
              mentor_profile: participant_profile,
              school:,
              remove_on_date: Time.current,
            )

            raise "Error removing mentor from school" if participant_mentoring_at_school?

            log_message("Marking participant as withdrawn")
            participant_profile.update!(status: :withdrawn)
          end

          log_message("Mentor removed from school")
        rescue StandardError => e
          log_error("Rolling back transaction")
          log_error(e.message)
        end

        def dry_run
          ActiveRecord::Base.transaction do
            call

            log_message("Dry run complete")
            log_message("Rolling back changes")

            raise ActiveRecord::Rollback
          end
        end

      private

        def participant_mentoring_at_school?
          school.school_mentors.reload.find_by(participant_profile:).present?
        end
      end
    end
  end
end
