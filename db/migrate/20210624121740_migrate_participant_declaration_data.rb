# frozen_string_literal: true

class MigrateParticipantDeclarationData < ActiveRecord::Migration[6.1]
  def up
    ParticipantDeclaration.find_each do |pd|
      ActiveRecord::Base.transaction do
        ProfileDeclaration.create(
          participant_declaration: pd,
          lead_provider: pd.lead_provider,
          early_career_profile_declaration: EarlyCareerTeacherProfileDeclaration.new(
            early_career_teacher_profile: pd.early_career_teacher_profile,
          )
        )
        pd&.update(user_id: pd.early_career_teacher_profile.user_id)
      end
    end
  end

  def down
    ProfileDeclaration.find_each do |ectpd|
      pd = ectpd.participant_declaration
      pd&.update(early_career_teacher_profile_id: ectpd.id)
    end
  end
end
