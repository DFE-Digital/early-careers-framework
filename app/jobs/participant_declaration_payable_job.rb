# frozen_string_literal: true

class ParticipantDeclarationPayableJob < ApplicationJob
  queue_as :default

  class << self
    def schedule
      set(wait_until: milestone + 10.hours)
    end

    def milestone
      Time.local(2021,11,1).to_s(:db)
    end
  end

  delegate :milestone, to: ParticipantDeclarationPayableJob

  def perform(*)
    ParticipantDeclaration.where(state: "eligible").where("declaration_date <= ?", milestone).where(declaration_type: "started").where("created_at <= ?", milestone).each(&:make_payable!)
  end
end
