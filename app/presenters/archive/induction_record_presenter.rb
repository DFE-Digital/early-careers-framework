# frozen_string_literal: true

module Archive
  class InductionRecordPresenter < RelicPresenter
    def fip?
      attribute(:training_programme) == "full_induction_programme"
    end

    def cip?
      attribute(:training_programme) == "core_induction_programme"
    end

    def schedule
      @schedule ||= Finance::Schedule.find(attribute(:schedule_id))
    end

    def start_date
      Time.zone.parse(attribute(:start_date))
    end

    def end_date
      Time.zone.parse(attribute(:end_date)) if attribute(:end_date).present?
    end

    def created_at
      Time.zone.parse(attribute(:created_at))
    end
  end
end
