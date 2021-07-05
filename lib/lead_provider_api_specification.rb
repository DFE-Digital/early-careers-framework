# frozen_string_literal: true

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
