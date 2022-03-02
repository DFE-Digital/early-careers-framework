# frozen_string_literal: true

module Pages
  class ParticipantsDashboard
    include Capybara::DSL

    def has_expected_content?
      has_selector?("h1", text: "Your ECTs and mentors") &&
        has_text?("Add a new ECT") &&
        has_text?("Add a new mentor") &&
        has_text?("Add yourself as a mentor")
    end

    def can_view_participants?(*participants)
      pass = true

      participants.each do |participant|
        unless has_text?(participant.user.full_name.to_s)
          pass = false
        end
      end

      pass
    end
  end
end
