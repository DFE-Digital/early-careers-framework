# frozen_string_literal: true

module Archive
  class Search < BaseService
    attr_reader :scope, :search_term, :type

    def initialize(scope = Archive::Relic, search_term: nil, type: nil)
      # make the scope overrideable so we can pass in one that's been
      # checked by Pundit from the controller
      @scope       = scope
      @search_term = search_term
      @type        = type
    end

    def call
      scope
        .merge(search_conditions)
        .merge(type_conditions)
        .order(display_name: :asc)
    end

  private

    def search_conditions
      if search_term.present?
        Archive::Relic.with_metadata_containing(search_term)
      else
        Archive::Relic.all
      end
    end

    def type_conditions
      if type.present?
        Archive::Relic.with_metadata_containing(type)
      else
        Archive::Relic.all
      end
    end
  end
end
