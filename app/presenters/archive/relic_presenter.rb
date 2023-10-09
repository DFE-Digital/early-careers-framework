# frozen_string_literal: true

module Archive
  class RelicPresenter
    attr_reader :relic
 
    def self.wrap(collection)
      collection.map do |relic|
        new relic
      end
    end

    def initialize(relic)
      @relic = relic
    end

    def id
      relic["id"]
    end

    def method_missing(m, *args, &block)
      if relic["attributes"].has_key?(m.to_s)
        attribute(m)
      else
        super
      end
    end

  private
    
    def attribute(name)
      relic.dig("attributes", name.to_s)
    end
  end
end
