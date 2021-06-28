# frozen_string_literal: true

class MigrateParticipantDeclarationData < ActiveRecord::Migration[6.1]
  def self.up
    ParticipantDeclaration.find_each do |pd|
      EarlyCareerTeacherProfileDeclaration.create(
        participant_declaration: pd,
        early_career_teacher_profile: pd.early_career_teacher_profile,
      )
    end
  end

  def self.down
    EarlyCareerTeacherProfileDeclaration.find_each do |ectpd|
      ParticipantDeclaration.find(ectpd.participant_id).update(early_career_teacher_profile_id: ectpd.id)
    end
  end
end
