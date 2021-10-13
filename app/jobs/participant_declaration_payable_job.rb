# frozen_string_literal: true

class ParticipantDeclarationPayableJob < ApplicationJob
  queue_as :default

  class << self
    def schedule
      set(wait_until: milestone_end + 10.hours)
    end

    def milestone_start
      Time.zone.local(2021, 9, 1).to_s(:db)
    end

    def milestone_end
      Time.zone.local(2021, 11, 1).to_s(:db)
    end
  end

  delegate :milestone_start, :milestone_end, to: ParticipantDeclarationPayableJob

  def perform(*)
    RecordDeclarations::Actions::MakeDeclarationsPayable.call(start_date: milestone_start, end_date: milestone_end)
  end
end
