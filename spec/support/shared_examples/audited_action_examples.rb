# frozen_string_literal: true

RSpec.shared_examples "audits changes" do
  let(:versions) do
    PaperTrail::Version.where.not(whodunnit: nil)
  end

  it "creates versions" do
    expect(versions).to exist
  end

  it "tracks whodunnit" do
    expect(versions.last.whodunnit).to eq current_admin.id
  end
end
