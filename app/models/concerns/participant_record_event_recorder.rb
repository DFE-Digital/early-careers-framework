# frozen_string_literal: true

# Currently a placeholder to ensure that transitioning to this doesn't break since the scopes will be different
# 1. Duplicate ect_profiles can be recorded, so we need to filter for uniqueness as a count
# 2. Order is reversed, to pick up the latest change to a user
# 3. Holding "retention_1" rather than "Retention 1" in the db, for example.

module Concerns
  module ParticipantRecordEventRecorder
    extend ActiveSupport::Concern
    included do
      scope :active, -> { where(event_type: "Start").order(created_at: desc).distinct_on(:early_career_teacher_profile_id) }
    end
  end
end
