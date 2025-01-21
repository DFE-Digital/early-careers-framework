# frozen_string_literal: true

class PopulateTypeFromTempTypeOnParticipantDeclarations < ActiveRecord::Migration[7.1]
  def up
    raise "Migration aborted: `temp_type` contains NULL values." if ParticipantDeclaration::ECF.where(temp_type: nil).exists?

    ParticipantDeclaration::ECF.find_in_batches(batch_size: 1_000) do |batch|
      ParticipantDeclaration.where(id: batch.map(&:id)).update_all("type = temp_type")
    end
  end

  def down
    ParticipantDeclaration::ECF.in_batches(of: 1_000) { |batch| batch.update_all(type: "ParticipantDeclaration::ECF") }
  end
end
