# frozen_string_literal: true

class ParticipantDeclarationPayJob < ApplicationJob
  queue_as :default

  class << self
    def schedule
      set(wait_until: payment_time + 10.hours)
    end

    def payment_time
      Time.zone.local(2021, 12, 1).to_s(:db)
    end
  end

  def perform(*)
    ParticipantDeclaration.payable.each(&:make_paid!)
  end
end
