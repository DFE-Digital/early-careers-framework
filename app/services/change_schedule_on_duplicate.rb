# frozen_string_literal: true

class ChangeScheduleOnDuplicate < ChangeSchedule
  attribute :profile

  validates :profile, presence: true

  def participant_profile
    profile
  end
end
