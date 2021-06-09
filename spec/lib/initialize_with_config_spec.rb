# frozen_string_literal: true

class MissingCallMethod
  include InitializeWithConfig
end

class CorrectStructure
  include InitializeWithConfig
  prevent_local_override

  def call
    config.to_h
  end

  # Local override of input method - prevented by the prevent_local_override class level declaration
  def band_a
    1000
  end
end

class InheritedStructure < CorrectStructure
  # Local override prevention must be declared for every class regardless of inheritance.
  def band_a
    2000
  end
end

class MissingParameter < CorrectStructure
  required_config :version, :event
end

describe "InitializeWithConfig" do
  let(:input) do
    {
      recruitment_target: 2000,
      band_a: BigDecimal(995, 10),
      retained_participants: HashWithIndifferentAccess.new({
        "Started" => 1900,
        "Retention 1" => 1700,
        "Retention 2" => 1500,
        "Retention 3" => 1000,
        "Retention 4" => 800,
        "Completion" => 500,
      }),
    }
  end

  let(:object) { CorrectStructure.new(input) }
  let(:inherited_object) { InheritedStructure.new(input) }

  it "creates an exception if the #call method is not defined for the class" do
    expect { MissingCallMethod.call(input) }.to raise_error(RuntimeError, "override abstract call method")
  end

  it "creates an exception if a required configuration parameter is not specified" do
    expect { MissingParameter.call(input) }.to raise_error(::InitializeWithConfig::MissingRequiredArguments, "missing required dependency injected items [:version, :event] in class MissingParameter")
  end

  it "creates an internal hash called 'config'" do
    expect(object.config).to be_a(Hash)
  end

  it "creates methods for the input keys" do
    expect(object.methods).to include(*input.keys)
  end

  it "prevents local method overrides if expliticly declared" do
    expect(object.band_a).to be(input[:band_a])
    expect(object.band_a).to_not be(1000)
  end

  it "creates methods that return the values of the input keys" do
    expect(object.recruitment_target).to be(input[:recruitment_target])
    expect(object.retained_participants).to be(input[:retained_participants])
  end

  it "creates methods that return the values of the input keys regardless of delegation" do
    expect(object.recruitment_target).to eq(object.config[:recruitment_target])
    expect(object.retained_participants).to eq(object.config[:retained_participants])
  end

  it "defaults inherited objects to allow overrides" do
    expect(inherited_object.band_a).to_not be(input[:band_a])
    expect(inherited_object.band_a).to be(2000)
  end
end
