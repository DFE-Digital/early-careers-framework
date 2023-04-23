# frozen_string_literal: true

module FullDQT
  class Record < SimpleDelegator
    def active?
      data["state_name"] == "Active"
    end

    def active_alert?
      data["active_alert"].present?
    end

    def date_of_birth
      data["dob"]
    end

    def exempt?
      data.dig("induction", "status") == "Exempt"
    end

    alias_method :exempt_from_induction?, :exempt?

    def induction_completion_date
      data.dig("induction", "completion_date")
    end

    def no_induction?
      induction_start_date.blank?
    end

    def previous_induction?
      induction_completion_date ||
        induction_start_date && induction_start_date < ActiveSupport::TimeZone["London"].local(2021, 9, 1)
    end

    def induction_start_date
      data.dig("induction", "start_date")
    end

    def name
      data["name"]
    end

    def name_matches?(full_name)
      full_name.present? && valid? && NameMatcher.new(full_name, name).matches?
    end

    def nino
      data["ni_number"]
    end

    def qts_date
      data.dig("qualified_teacher_status", "qts_date")
    end

    def qts?
      qts_date.present?
    end

    def trn
      data["trn"]
    end

    def valid?
      data.present?
    end

  private

    def data
      @data ||= Hash(__getobj__)
    end
  end
end
