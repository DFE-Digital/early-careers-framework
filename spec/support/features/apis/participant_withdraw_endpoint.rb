# frozen_string_literal: true

module APIs
  class ParticipantWithdrawEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    def initialize(token)
      @token = token
      @session = ActionDispatch::Integration::Session.new(Rails.application)
    end

    def post_withdraw_notice(participant)
      post_notice participant
    end

  private

    def post_notice(participant)
      params = build_params({
        reason: "moved-school",
        course_identifier: "ecf-induction",
      })

      @session.put "/api/v1/participants/#{participant.user.id}/withdraw",
                   headers: {
                     "Authorization": "Bearer #{@token}",
                     "Content-type": "application/json",
                   },
                   params: params

      data = JSON.parse(@session.response.body)["data"] || {}
      data["attributes"] || {}
    end

    def build_params(attributes)
      {
        data: {
          type: "participant-withdraw",
          attributes: attributes,
        },
      }.to_json
    end
  end
end
