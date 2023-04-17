# frozen_string_literal: true

module DeliveryPartnerProfiles
  class SearchQuery
    attr_reader :query, :scope

    def initialize(query:, scope: DeliveryPartnerProfile.all)
      @query = query.strip
      @scope = scope
    end

    def call
      scope
        .includes(:user, :delivery_partner)
        .where("users.full_name ILIKE ?", "%#{query}%")
        .or(scope.where("users.email ILIKE ?", "%#{query}%"))
        .or(scope.where("delivery_partners.name ILIKE ?", "%#{query}%"))
        .order("users.full_name ASC")
    end
  end
end
