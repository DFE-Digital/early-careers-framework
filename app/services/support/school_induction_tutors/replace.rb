# frozen_string_literal: true

module Support
  module SchoolInductionTutors
    class Replace
      class << self
        def call(school_urn:, email:, full_name:)
          new(school_urn:, email:, full_name:).call
        end
      end

      attr_reader :school, :email, :full_name

      def initialize(school_urn:, email:, full_name:)
        @school = School.find_by!(urn: school_urn)
        @email = email
        @full_name = full_name
      end

      def call
        log_existing_information

        CreateInductionTutor.call(school:, email:, full_name:)

        log_updated_information
      rescue StandardError => e
        logger.error(e)
      end

    private

      def log_existing_information
        logger.info("Replacing SIT for #{school.name} (URN: #{school.urn})")

        if school.induction_tutor.present?
          logger.info("Existing SIT: #{school.induction_tutor.full_name} - #{school.induction_tutor.email} (ID: #{school.induction_tutor.id})")
        else
          logger.info("No existing SIT")
        end
      end

      def log_updated_information
        school.reload

        logger.info("New SIT: #{school.induction_tutor.full_name} - #{school.induction_tutor.email} (ID: #{school.induction_tutor.id})")
        logger.info("Replaced SIT for #{school.name} (URN: #{school.urn})")
      end

      def log_error(error)
        logger.error("Failed to update SIT for #{school.name} (URN: #{school.urn})")
        logger.error(error.message)
      end

      def logger
        @logger = Logger.new($stdout)
      end
    end
  end
end
