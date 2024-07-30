# frozen_string_literal: true

return unless Rails.env.separation?

api_reference_path = Rails.root.join("public/api-reference")
api_reference_without_npq_path = Rails.root.join("public/api-reference-without-npq")

if [api_reference_path, api_reference_without_npq_path].all? { |d| Dir.exist?(d) }
  # Remove the existing 'api-reference' directory
  FileUtils.rm_rf(api_reference_path)

  # Move 'api-reference-without-npq' to 'api-reference'
  FileUtils.mv(api_reference_without_npq_path, api_reference_path) if Dir.exist?(api_reference_without_npq_path)
end
