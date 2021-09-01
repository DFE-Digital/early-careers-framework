module Participants
  module ChangeSchedule
    module ScheduleValidation
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :schedule_identifier
        validates :schedule, presence: { message: I18n.t(:invalid_schedule) }
      end

      def schedule
        Finance::Schedule.find_by(schedule_identifier: schedule_identifier)
      end
    end
  end
end
