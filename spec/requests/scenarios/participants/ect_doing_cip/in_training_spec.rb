# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ECT doing CIP in training", type: :request do
  include_context "a system that has the current academic year configured", 2023
  include_context "an appropriate body", "Appropriate Body One"
  include_context "a school that has chosen CIP as their default induction programme", "School chosen CIP in 2023"

  include_context "an ECF participant", NewSeeds::Scenarios::Participants::Ects::EctInTraining

  include_examples "As their current school induction tutor"
  include_examples "As their current appropriate body"
  include_examples "As the support for ECTs service", programme_type: "core_induction_programme", materials: "edt"

  # as a DfE Admin user

  # as a DfE Finance user
end
