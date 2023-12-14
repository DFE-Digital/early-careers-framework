# frozen_string_literal: true

module Oneoffs::Migration
  class Reconciler
    def orphaned
      @orphaned ||= matches.select(&:orphaned?)
    end

    def duplicated
      @duplicated ||= matches.select(&:duplicated?)
    end

    def matched
      @matched ||= matches - (orphaned + duplicated)
    end

    def matches
      @matches ||= begin
        matched_objects = Set.new
        matches = []

        all_objects.each do |obj|
          next if matched_objects.include?(obj)

          matching_objects = indexer.lookup(obj)
          matched_objects.merge(matching_objects)
          matches << Match.new(matching_objects)
        end

        matches
      end
    end

    def indexes
      raise NoMethodError, "subclass must implement #indexes"
    end

    def orphan_matches
      raise NoMethodError, "subclass must implement #orphan_matches"
    end

  protected

    def all_objects
      raise NoMethodError, "subclass must implement #all_objects"
    end

  private

    def indexer
      @indexer ||= Indexer.new(indexes, all_objects)
    end
  end
end
