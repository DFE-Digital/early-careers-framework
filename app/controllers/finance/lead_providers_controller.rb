# frozen_string_literal: true

class Finance::LeadProvidersController < Finance::BaseController
  def index
    @lead_providers = LeadProvider.all
  end
end
