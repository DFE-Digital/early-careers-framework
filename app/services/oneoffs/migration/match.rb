# frozen_string_literal: true

module Oneoffs::Migration
  class Match
    class NotOrphanedError < RuntimeError; end

    attr_reader :matches

    def initialize(matches)
      raise ArgumentError, "matches must be a Set" unless matches.is_a?(Set)

      @matches = matches
    end

    def orphan
      raise NotOrphanedError unless orphaned?

      matches.first
    end

    def orphaned?
      matches.size == 1
    end

    def duplicated?
      matches.size > 2
    end
  end
end
