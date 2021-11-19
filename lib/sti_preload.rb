# frozen_string_literal: true

# taken from https://github.com/rails/rails/blob/main/guides/source/autoloading_and_reloading_constants.md#single-table-inheritance
# There was apparently some problems with autoloading of ParticipantProfile::ECF
# The problem was not described, but the previous fix was not working on CI
module STIPreload
  unless Rails.application.config.eager_load
    extend ActiveSupport::Concern

    included do
      cattr_accessor :preloaded, instance_accessor: false
    end

    class_methods do
      def descendants
        preload_sti unless preloaded
        super
      end

      # Constantizes all types present in the database. There might be more on
      # disk, but that does not matter in practice as far as the STI API is
      # concerned.
      #
      # Assumes store_full_sti_class is true, the default.
      def preload_sti
        types_in_db = \
          base_class
            .unscoped
            .select(inheritance_column)
            .distinct
            .pluck(inheritance_column)
            .compact

        types_in_db.each do |type|
          logger.debug("Preloading STI type #{type}")
          type.constantize
        end

        self.preloaded = true
      end
    end
  end
end
