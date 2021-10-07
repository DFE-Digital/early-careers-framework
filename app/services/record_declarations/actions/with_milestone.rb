module RecordDeclarations
  module Actions
    module WithMilestone
      extend ActiveSupport::Concern

      included do
        extend WithMilestoneClassMethods
      end

      module WithMilestoneClassMethods
        def call(milestone:)
          new(milestone: milestone).call
        end
      end

      private
      attr_reader :milestone

      def initialize(milestone:)
        @milestone=milestone
      end
    end
  end
end
