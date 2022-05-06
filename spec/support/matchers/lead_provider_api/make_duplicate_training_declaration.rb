# frozen_string_literal: true

module Support
  module MakeDuplicateTrainingDeclarations
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :make_duplicate_training_declaration do |participant_name, participant_type, declaration_type|
      match do |lead_provider_name|
        make_training_declaration lead_provider_name, participant_name, participant_type, declaration_type

        true
      rescue Capybara::ElementNotFound => e
        @error = e

        false
      end

      match_when_negated do |lead_provider_name|
        make_training_declaration lead_provider_name

        false
      rescue StandardError => e
        @error = e

        true
      end

      def make_training_declaration(lead_provider_name, participant_name, participant_type, declaration_type)
        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant_profile = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant_profile.nil?

        case declaration_type
        when :started
          timestamp = participant_profile.schedule.milestones.first.start_date + 10.days
        when :retained_1
          timestamp = participant_profile.schedule.milestones.second.start_date + 10.days
        else
          puts "Unexpected declaration type \"#{declaration_type}\""
        end

        course_identifier = participant_type == "ECT" ? "ecf-induction" : "ecf-mentor"

        travel_to(timestamp) do
          puts timestamp

          declarations_endpoint = APIs::PostParticipantDeclarationsEndpoint.load tokens[lead_provider_name]
          declarations_endpoint.post_training_declaration participant_profile.user.id, course_identifier, declaration_type, timestamp - 8.days

          @text = declarations_endpoint.response

          expect(declarations_endpoint).to have_declaration_type(declaration_type.to_s)
          expect(declarations_endpoint).to have_eligible_for_payment(false)
          expect(declarations_endpoint).to have_voided(false)
          expect(declarations_endpoint).to have_state("ineligible")
        end
      end

      failure_message do |lead_provider_name|
        return @error unless @error.nil?

        "'#{lead_provider_name}' Should have been blocked from making the declaration '#{declaration_type}' for the training of '#{participant_name}' through the ecf declarations endpoint"
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' Should not have been blocked from making the declaration '#{declaration_type}' for the training of '#{participant_name}' through the ecf declarations endpoint"
      end

      description do
        "be blocked from making the declaration #{declaration_type} for the training of '#{participant_name}' through the ecf declarations endpoint"
      end
    end
  end
end
