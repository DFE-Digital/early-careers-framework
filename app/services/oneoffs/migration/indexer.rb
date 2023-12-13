# frozen_string_literal: true

module Oneoffs::Migration
  class Indexer
    class UnindexableError < ArgumentError; end
    class NoIndexesError < ArgumentError; end

    attr_reader :indexes, :objects

    def initialize(indexes, objects)
      @indexes = indexes
      @objects = objects

      raise NoIndexesError, "you must specify indexes" if indexes.blank?
    end

    # Looks up objects in the index that match the passed in
    # object (based on the indexed attributes). It will recursively
    # perform a lookup on any matched objects in order to expand the
    # search as far as possible and infer matches.
    def lookup(obj, looked_up_objects = Set.new)
      return Set[obj] if looked_up_objects.include?(obj)

      looked_up_objects.add(obj)

      indexes
        .map { |attr| fetch(obj, attr) }
        .flatten
        .reduce(Set.new, &:merge)
        .flat_map { |matching_obj| lookup(matching_obj, looked_up_objects) }
        .reduce(Set.new, &:merge)
    end

  private

    def fetch(obj, attr)
      keys = sanitize_keys(obj, attr)
      keys.map { |k| index.dig(attr, k) }.compact
    end

    def index
      @index ||= indexes.index_with { {} }.tap do |index|
        objects.each { |obj| index_object(obj, index) }
      end
    end

    def index_object(obj, index)
      results = indexes.map { |attr| index_object_attribute(obj, index, attr) }

      raise UnindexableError, "unable to index #{obj}" if results.all?(&:nil?)
    end

    def index_object_attribute(obj, index, attr)
      keys = sanitize_keys(obj, attr)
      return if keys.blank?

      keys.each do |key|
        index[attr][key] ||= Set.new
        index[attr][key].add(obj)
      end
    end

    def sanitize_keys(obj, attr)
      return Set.new unless obj.respond_to?(attr)

      keys = Array.wrap(obj.send(attr))
      keys.map { |v| v.to_s.downcase }
    end
  end
end
