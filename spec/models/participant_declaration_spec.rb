# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration, type: :model do
  before :each do
    @participant_declaration = create(:participation_record)
  end
  let(:set_config_ect_profile) { create(:early_career_teacher_profile) }

  xit "should record participant declarations" do

  end

end
