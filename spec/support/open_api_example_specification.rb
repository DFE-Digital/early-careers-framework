# frozen_string_literal: true

class OpenApiExampleSpecification
  BOILERPLATE = <<~YAML
    openapi: '3.0.1'
    info:
      version: v1
    paths: {}
  YAML

  def self.build_with(yaml)
    spec = YAML.safe_load(BOILERPLATE)
    spec.merge(YAML.safe_load(yaml))
  end
end
