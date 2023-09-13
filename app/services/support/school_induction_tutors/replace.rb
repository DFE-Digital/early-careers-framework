module Support
  module SchoolInductionTutors
    class Replace
      class << self
        def call(school_id:, email:, full_name:)
          new(school_id: school_id, email: email, full_name: full_name).call
        end
      end

      attr_reader :school, :email, :full_name

      def initialize(school_id:, email:, full_name:)
        @school = School.find(school_id)
        @email = email
        @full_name = full_name
      end

      def call
        log_existing_information

        CreateInductionTutor.call(school: school, email: email, full_name: full_name)

        log_updated_information
      rescue => e
        log_error(e)
      end

      private

      def log_existing_information
        Rails.logger.info("Replacing SIT for #{school.name} (ID: #{school.id})")

        if school.induction_tutor.present?
          Rails.logger.info("Existing SIT: #{school.induction_tutor.full_name} #{school.induction_tutor.email} (ID: #{school.induction_tutor.id})")
        else
          Rails.logger.info("No existing SIT")
        end
      end

      def log_updated_information
        school.reload

        Rails.logger.info("Replaced SIT for #{school.name} (ID: #{school.id})")
        Rails.logger.info("New SIT: #{school.induction_tutor.full_name} #{school.induction_tutor.email} (ID: #{school.induction_tutor.id})")
      end

      def log_error(error)
        Rails.logger.error("Failed to update SIT for #{school.name} (ID: #{school.id})")
        Rails.logger.error(error.message)
      end
    end
  end
end
