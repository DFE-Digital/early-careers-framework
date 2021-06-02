# frozen_string_literal: true

##
# Current state of participants (teachers and mentors), i.e. users on a course (ECF or NPQ).
#
# Transition history is recorded by `paper_trail`.
#
# You can generate a state diagram with `bundle exec rake aasm-diagram:generate[participant_profile]`
# The generated diagram goes into the `tmp/` folder of the repo. See https://github.com/Katee/aasm-diagram
module Concerns
  module ParticipantRecordStateMachine
    extend ActiveSupport::Concern
    included do
      include AASM

      has_paper_trail versions: {
        class_name: "ParticipantEvent",
      }

      scope :active, -> { where(state: "active") }
      scope :changed_between, lambda { |start_date, end_date| where(updated_at: start_date..end_date)}

      aasm column: :state

      aasm do
        state :assigned, initial: true
        state :active, :deferred, :withdrawn, :completed
        before_all_events :before_all_events

        event :join do
          transitions from: :assigned, to: :active
        end

        event :defer do
          transitions from: :active, to: :deferred
        end

        event :resume do
          transitions from: :deferred, to: :active
        end

        event :withdraw do
          transitions from: %i[active deferred], to: :withdrawn
        end

        event :complete do
          transitions from: :active, to: :completed
        end
      end
    end

    def before_all_events
      self.paper_trail_event = aasm.current_event
    end
  end
end
