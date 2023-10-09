# frozen_string_literal: true

module Archive
  class InductionRecordPresenter < RelicPresenter
    def schedule
      @schedule ||= Finance::Schedule.find(attribute(:schedule_id))
    end

    def start_date
      DateTime.parse(attribute(:start_date))
    end

    def end_date
      DateTime.parse(attribute(:end_date)) unless attribute(:end_date).blank?
    end

    def created_at
      DateTime.parse(attribute(:created_at))
    end
  end
end
