# frozen_string_literal: true

module LeadProviderProfiles
  class SearchQuery
    attr_reader :query, :scope

    def initialize(query:, scope: LeadProviderProfile.all)
      @query = query.strip
      @scope = scope
    end

    def call
      scope
        .includes(:user, :lead_provider)
        .where("users.full_name ILIKE ?", "%#{query}%")
        .or(scope.where("users.email ILIKE ?", "%#{query}%"))
        .or(scope.where("lead_providers.name ILIKE ?", "%#{query}%"))
        .order("users.full_name ASC")
    end
  end
end
