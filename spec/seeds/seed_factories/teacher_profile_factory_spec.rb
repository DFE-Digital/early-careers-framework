# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_teacher_profile") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_teacher_profile }
    let(:factory_class) { TeacherProfile }
  end
end
