# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::ECF do
  it { is_expected.to belong_to(:statement).class_name("Finance::Statement::ECF").optional }
end
