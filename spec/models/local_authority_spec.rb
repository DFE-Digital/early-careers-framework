# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocalAuthority, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:school_local_authorities) }
    it { is_expected.to have_many(:schools).through(:school_local_authorities) }
  end
end
