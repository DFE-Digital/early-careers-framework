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

    def meta
      relic["meta"]
    end

    def method_missing(method_name, *args, &block)
      if relic["attributes"].key?(method_name.to_s)
        attribute(method_name)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      relic["attributes"].key?(method_name.to_s) || super
    end

  private

    def attribute(name)
      relic.dig("attributes", name.to_s)
    end
  end
end
