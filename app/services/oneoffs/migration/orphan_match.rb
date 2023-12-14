# frozen_string_literal: true

module Oneoffs::Migration
  class OrphanMatch
    attr_reader :orphan, :potential_matches

    def initialize(orphan, potential_matches)
      @orphan = orphan
      @potential_matches = potential_matches
    end
  end
end
