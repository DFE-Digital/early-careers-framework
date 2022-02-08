# frozen_string_literal: true

class ChangeDefaultStartTermOnParticipantProfile < ActiveRecord::Migration[6.1]
  def up
    change_column_default :participant_profiles, :start_term, "autumn_2021"

    ParticipantProfile.where(start_term: "Autumn 2021").update_all(start_term: "autumn_2021")
    ParticipantProfile.where(start_term: "Spring 2022").update_all(start_term: "spring_2022")
    ParticipantProfile.where(start_term: "Summer 2022").update_all(start_term: "summer_2022")
  end

  def down
    change_column_default :participant_profiles, :start_term, "Autumn 2021"

    ParticipantProfile.where(start_term: "autumn_2021").update_all(start_term: "Autumn 2021")
    ParticipantProfile.where(start_term: "spring_2022").update_all(start_term: "Spring 2022")
    ParticipantProfile.where(start_term: "summer_2022").update_all(start_term: "Summer 2022")
  end
end
