# frozen_string_literal: true

class Finance::Invoice::NPQ
  attr_reader :interval, :name, :payment_date, :deadline_date

  def initialize(milestone:, name:)
    @interval = milestone.start_date..milestone.milestone_date
    @name = name
    @payment_date = milestone.payment_date
    @deadline_date = @interval.end
  end

  class << self
    def find_current_milestone
      Finance::Milestone
        .joins(:schedule)
        .where(Finance::Schedule.arel_table[:name].matches("%NPQ%"))
        .where(start_date: ..Time.zone.today, milestone_date: Time.zone.today..).first
    end

    def find_payable_milestone
      Finance::Milestone
        .joins(:schedule)
        .where(Finance::Schedule.arel_table[:name].matches("%NPQ%"))
        .where(milestone_date: ..Time.zone.today)
        .order(start_date: :desc).first
    end

    def current
      @current ||= Finance::Invoice::NPQ.new(milestone: find_current_milestone, name: "current")
    end

    def payable
      @payable ||= Finance::Invoice::NPQ.new(milestone: find_payable_milestone, name: "payable")
    end
  end
end
