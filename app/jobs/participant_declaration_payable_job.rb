# frozen_string_literal: true

class ParticipantDeclarationPayableJob < ApplicationJob
  queue_as :default

  class << self
    def schedule
      set(wait_until: milestone_end + 10.hours)
    end

    def milestone_start
      Time.local(2021,9,1).to_s(:db)
    end

    def milestone_end
      Time.local(2021,12,1).to_s(:db)
    end
  end

  delegate :milestone_start, :milestone_end, to: ParticipantDeclarationPayableJob

  def perform(*)
    ParticipantDeclaration.eligible.declared_as_between(milestone_start, milestone_end).submitted_between(milestone_start, milestone_end).each(&:make_payable!)
  end
end
