# frozen_string_literal: true

class ConvertParticipantDeclarationsLeadProviderToCpdLeadProvider < ActiveRecord::Migration[6.1]
  class ParticipantDeclarations < ApplicationRecord
    belongs_to :cpd_lead_provider
  end

  class LeadProvider < ApplicationRecord
    has_many :participant_declarations
    belongs_to :cpd_lead_provider
  end

  class CPDLeadProvider < ApplicationRecord
    has_many :participant_declarations
    has_one :lead_provider
  end

  class ParticipantDeclaration::ECF < ParticipantDeclaration
    belongs_to :cpd_lead_provider
    belongs_to :lead_provider
  end

  def up
    ParticipantDeclaration.find_each do |participant_declaration|
      participant_declaration.update!(cpd_lead_provider: participant_declaration.lead_provider.cpd_lead_provider, course_identifier: participant_declaration.course_type)
    end
  end

  def down
    ParticipantDeclaration::ECF.find_each do |participant_declaration|
      participant_declaration.update!(lead_provider: participant_declaration.cpd_lead_provider.lead_provider, course_type: participant_declaration.course_identifier)
    end
  end
end
