# frozen_string_literal: true

require_relative "./shared_factory_examples"

RSpec.describe("seed_npq_course_factory") do
  it_behaves_like("a seed factory") do
    let(:factory_name) { :seed_npq_course }
    let(:factory_class) { NPQCourse }
  end
end
