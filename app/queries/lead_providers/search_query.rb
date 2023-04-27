# frozen_string_literal: true

module LeadProviders
  class SearchQuery
    attr_reader :query, :scope

    def initialize(query:, scope: LeadProvider.all)
      @query = query
      @scope = scope
    end

    def call
      scope
        .distinct
        .ransack(name_cont: query)
        .result
        .order(:name)
    end
  end
end
