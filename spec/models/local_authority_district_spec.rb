# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocalAuthorityDistrict, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:school_local_authority_districts) }
    it { is_expected.to have_many(:schools).through(:school_local_authority_districts) }
  end
end
