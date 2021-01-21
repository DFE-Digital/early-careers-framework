# frozen_string_literal: true

class CoreInductionProgrammeController < ApplicationController
  def show
    @lead_providers = LeadProvider.all
  end
end
