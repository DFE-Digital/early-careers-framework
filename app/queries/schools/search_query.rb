# frozen_string_literal: true

module Schools
  class SearchQuery
    attr_reader :query, :scope

    def initialize(query:, scope: School.all)
      @query = query
      @scope = scope
    end

    def call
      scope
        .distinct
        .includes(:induction_coordinators, :local_authority)
        .ransack(induction_coordinators_email_or_urn_or_name_or_postcode_cont: query)
        .result
        .order(:name)
    end
  end
end
