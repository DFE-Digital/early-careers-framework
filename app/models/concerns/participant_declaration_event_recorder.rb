# frozen_string_literal: true

# Currently a placeholder to ensure that transitioning to this doesn't break since the scopes will be different
# 1. Duplicate ect_profiles can be recorded, so we need to filter for uniqueness as a count
# 2. Order is reversed, to pick up the latest change to a user
# 3. Holding "retention_1" rather than "Retention 1" in the db, for example.

module Concerns
  module ParticipantDeclarationEventRecorder
    extend ActiveSupport::Concern
    included do
      scope :unique_early_career_teacher_profile_id, -> { select(:early_career_teacher_profile_id).distinct }
      scope :active, -> { where(declaration_type: "Start").order(declaration_date: "desc").unique_early_career_teacher_profile_id }
      scope :declared_as_between, lambda { |start_date, end_date| where(declaration_date: start_date..end_date)}
      scope :submitted_between, lambda { |start_date, end_date| where(created_at: start_date..end_date)}
    end
  end
end
