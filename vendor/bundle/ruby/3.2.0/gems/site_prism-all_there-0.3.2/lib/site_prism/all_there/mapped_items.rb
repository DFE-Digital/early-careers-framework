# frozen_string_literal: true

module SitePrism
  module AllThere
    #
    # @api private
    #
    # The Mapped Items on a SitePrism Page or Section
    class MappedItems
      attr_reader :instance
      private :instance

      def initialize(instance)
        @instance = instance
      end

      # @return [Array<Symbol>]
      # All expected mapped items on the SitePrism instance as a Symbol Array
      def array
        hash.values.flatten.uniq
      end

      # @return [Hash<Symbol>]
      # All expected mapped items on the SitePrism instance as a Symbol Hash
      def hash
        instance.class.mapped_items(legacy: false)
      end
    end
  end
end
