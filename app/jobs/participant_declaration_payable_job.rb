class ParticipantDeclarationPayableJob < ApplicationJob
  queue_as :default

  class << self
    def schedule
      set(wait_until: milestone + 10.hours)
    end

    def milestone
      TimeWithZone.new("2021-11-01T00:00:00Z")
    end
  end

  def perform(*)
    ParticipantDeclaration.where(declaration_date: "<#{milestone.to_s}").where(declaration_type: "started").where(created_at: "<#{milestone.to_s}").each do |participant_declaration|
      participant_declaration.make_payable!
    end
  end
end
