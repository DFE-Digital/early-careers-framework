# frozen_string_literal: true

# See https://github.com/Casecommons/with_model/issues/35

module WithModel
  class Model
    # Workaround for https://github.com/Casecommons/with_model/issues/35
    def cleanup_descendants_tracking
      if defined?(ActiveSupport::DescendantsTracker) && !Rails.application.config.cache_classes
        ActiveSupport::DescendantsTracker.clear([@model])
      elsif @model.superclass.respond_to?(:direct_descendants)
        @model.superclass.subclasses.delete(@model)
      end
    end
  end
end
