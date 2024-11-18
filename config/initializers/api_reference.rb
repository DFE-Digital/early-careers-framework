# frozen_string_literal: true

# Only run this initializer in the context of a Rails server.
return unless defined?(Rails::Server)

# Ensure autoloading as finished.
Rails.application.config.after_initialize do
  # Wait for database connection to be established.
  ActiveRecord::Base.connection_pool.with_connection do
    if FeatureFlag.active?(:disable_npq)
      api_reference_path = Rails.root.join("public/api-reference")
      api_reference_without_npq_path = Rails.root.join("public/api-reference-without-npq")

      if [api_reference_path, api_reference_without_npq_path].all? { |d| Dir.exist?(d) }
        # Remove the existing 'api-reference' directory
        FileUtils.rm_rf(api_reference_path)

        # Move 'api-reference-without-npq' to 'api-reference'
        FileUtils.mv(api_reference_without_npq_path, api_reference_path)
      end
    end
  end
end
