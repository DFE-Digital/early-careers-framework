# frozen_string_literal: true

module Archive
  class Search < BaseService
    attr_reader :scope, :search_term, :role

    def initialize(scope = Archive::Relic, search_term: nil, role: nil)
      # make the scope overrideable so we can pass in one that's been
      # checked by Pundit from the controller
      @scope       = scope
      @search_term = search_term
      @role        = role
    end

    def call
      scope
        .merge(search_conditions)
        .merge(role_conditions)
        .order(order)
    end

  private

    def search_conditions
      if search_term.present?
        Archive::Relic.with_metadata_containing(search_term)
      else
        Archive::Relic.all
      end
    end

    def role_conditions
      if role.present?
        Archive::Relic.with_metadata_containing(role)
      else
        Archive::Relic.all
      end
    end

    def order
      Arel.sql("data->'meta'->>'full_name' ASC")
    end
  end
end
