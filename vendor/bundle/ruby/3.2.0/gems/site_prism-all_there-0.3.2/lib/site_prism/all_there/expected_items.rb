# frozen_string_literal: true

module SitePrism
  module AllThere
    #
    # @api private
    #
    # The Expected Item Map on a SitePrism Page or Section
    class ExpectedItems
      attr_reader :instance
      private :instance

      def initialize(instance)
        @instance = instance
      end

      # @return [Array<Hash<Symbol>>]
      # All expected mapped items
      def array
        [
          element,
          elements,
          section,
          sections,
          iframe,
        ]
      end

      # @return [Hash<Symbol>]
      # All expected items that were mapped as +element+
      def element
        mapped_checklist_of(:element)
      end

      # @return [Hash<Symbol>]
      # All expected items that were mapped as +elements+
      def elements
        mapped_checklist_of(:elements)
      end

      # @return [Hash<Symbol>]
      # All expected items that were mapped as +section+
      def section
        mapped_checklist_of(:section)
      end

      # @return [Hash<Symbol>]
      # All expected items that were mapped as +sections+
      def sections
        mapped_checklist_of(:sections)
      end

      # @return [Hash<Symbol>]
      # All expected items that were mapped as +iframe+
      def iframe
        mapped_checklist_of(:iframe)
      end

      private

      def mapped_checklist_of(type)
        mapped_items.hash[type].select { |name| mapped_checklist.include?(name) }
      end

      def mapped_checklist
        if checklist
          SitePrism.logger.debug('Expected Items has been set.')
          mapped_items.array.select { |name| checklist.include?(name) }
        else
          mapped_items.array
        end
      end

      def checklist
        instance.class.expected_items
      end

      def mapped_items
        @mapped_items ||= MappedItems.new(instance)
      end
    end
  end
end
