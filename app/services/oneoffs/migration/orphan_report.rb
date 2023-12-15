# frozen_string_literal: true

module Oneoffs::Migration
  class OrphanReport
    attr_reader :reconciler

    def initialize(reconciler)
      @reconciler = reconciler
    end

    def to_yaml
      orphaned_matches.map { |orphan_match|
        {
          orphan: extract_attributes(orphan_match.orphan),
          potential_matches: orphan_match.potential_matches.map(&method(:extract_attributes)),
        }
      }.to_yaml
    end

  private

    def extract_attributes(obj)
      attributes.index_with { |attr| obj.send(attr).to_s.presence }.compact
    end

    def attributes
      %i[class] + reconciler.indexes
    end

    def orphaned_matches
      reconciler.orphaned_matches
    end
  end
end
