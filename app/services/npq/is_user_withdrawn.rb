# frozen_string_literal: true

module NPQ
  class IsUserWithdrawn
    attr_reader :user, :cpd_lead_provider

    def initialize(user:, cpd_lead_provider:)
      @user = user
      @cpd_lead_provider = cpd_lead_provider
    end

    def call
      active_npq_profiles.none?
    end

  private

    def active_npq_profiles
      scope = user.npq_profiles
      scope = scope.joins(npq_application: { npq_lead_provider: [:cpd_lead_provider] })
      scope = scope.where(npq_applications: { npq_lead_providers: { cpd_lead_provider: cpd_lead_provider } })
      scope = scope.where.not(training_status: "withdrawn")
      scope.where.not(status: "withdrawn")
    end
  end
end
