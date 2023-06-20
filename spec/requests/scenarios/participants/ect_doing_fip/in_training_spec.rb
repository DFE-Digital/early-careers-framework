# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ECT doing FIP in training", type: :request do
  include_context "a system that has the current academic year configured", 2023
  include_context "an appropriate body", "Appropriate Body One"
  include_context "a lead provider and their delivery partner", "Lead Provider One", "Delivery Partner One"
  include_context "a school that has chosen FIP as their default induction programme", "School chosen FIP in 2023"

  include_context "an ECF participant", NewSeeds::Scenarios::Participants::Ects::EctInTraining

  include_examples "As their current school induction tutor"
  include_examples "As their current appropriate body"
  include_examples "As their current lead provider"
  include_examples "As their current delivery provider"
  include_examples "As the support for ECTs service", programme_type: "full_induction_programme"

  # as a DfE Admin user

  # as a DfE Finance user
end
