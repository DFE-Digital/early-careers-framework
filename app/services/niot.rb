# frozen_string_literal: true

class Niot
  NAME = "National Institute of Teaching"

  def self.lead_provider
    LeadProvider.find_by_name(NAME)
  end

  def self.first_training_year
    lead_provider&.first_training_year
  end
end
