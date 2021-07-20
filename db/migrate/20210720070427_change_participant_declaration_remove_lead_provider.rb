# frozen_string_literal: true

class ChangeParticipantDeclarationRemoveLeadProvider < ActiveRecord::Migration[6.1]
  class ParticipantDeclaration < ApplicationRecord
    self.ignored_columns = %w[lead_provider_id course_type]
  end

  def change
    safety_assured do
      remove_reference :participant_declarations, :lead_provider, foreign_key: true, type: :uuid
      remove_column :participant_declarations, :course_type,  :string, foreign_key: false
    end
  end
end
