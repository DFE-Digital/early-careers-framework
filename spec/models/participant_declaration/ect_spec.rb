# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::ECT do
  it { is_expected.to be_a(ParticipantDeclaration::ECF) }
end
