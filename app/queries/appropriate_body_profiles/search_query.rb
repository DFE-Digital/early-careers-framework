# frozen_string_literal: true

module AppropriateBodyProfiles
  class SearchQuery
    attr_reader :query, :scope

    def initialize(query:, scope: AppropriateBodyProfile.all)
      @query = query.strip
      @scope = scope
    end

    def call
      scope
        .includes(:user, :appropriate_body)
        .where("users.full_name ILIKE ?", "%#{query}%")
        .or(scope.where("users.email ILIKE ?", "%#{query}%"))
        .or(scope.where("appropriate_bodies.name ILIKE ?", "%#{query}%"))
        .order("users.full_name ASC")
    end
  end
end
