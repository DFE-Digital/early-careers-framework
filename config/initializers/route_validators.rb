# frozen_string_literal: true

class ValidLeadProviderApiRoute
  def self.matches?(request)
    LeadProviderApiSpecification::VERSIONS.include?(request.params[:api_version])
  end
end
