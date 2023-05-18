# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/lib/vendor_api_specification.rb

class LeadProviderApiSpecification
  CURRENT_VERSION = "v3"
  VERSIONS = %w[v1 v2 v3].freeze

  def self.as_yaml(version = CURRENT_VERSION)
    spec(version).to_yaml
  end

  def self.as_hash(version = CURRENT_VERSION)
    spec(version)
  end

  def self.spec(version = CURRENT_VERSION)
    YAML.load_file("swagger/#{version}/api_spec.json")
  end
end
