# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/lib/vendor_api_specification.rb

class LeadProviderApiSpecification
  def self.as_yaml
    spec.to_yaml
  end

  def self.as_hash
    spec
  end

  def self.spec
    YAML.load_file("swagger/v1/api_spec.json")
  end
end
