# frozen_string_literal: true

module Support
  module BeReportedToSupportForECTsAs
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_reported_to_support_for_ect_as do |programme, participant_type|
      match do |participant_name|
        user_endpoint = APIs::ECFUsersEndpoint.new

        case programme
        when "FIP"
          user_endpoint.user_is_fip_ect?(participants[participant_name])
        when "CIP"
          user_endpoint.user_is_cip_ect?(participants[participant_name])
        end
      end

      failure_message do |participant_name|
        "#{participant_name} is not reported to Support ECTs as an ECT on the #{programme} programme"
      end

      failure_message_when_negated do |participant_name|
        "#{participant_name} is reported to Support ECTs as an ECT on the #{programme} programme"
      end

      description do
        "be reported to Support for ECTs as a #{participant_type} doing a #{programme}"
      end
    end
  end
end
