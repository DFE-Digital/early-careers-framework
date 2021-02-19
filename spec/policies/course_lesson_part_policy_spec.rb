# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseLessonPartPolicy, type: :policy do
  subject { described_class.new(user, course_lesson_part) }
  let(:course_lesson_part) { create(:course_lesson_part) }

  context "editing as admin" do
    let(:user) { create(:user, :admin) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_edit_and_update_actions }
  end

  context "trying to edit as user" do
    let(:user) { create(:user) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_edit_and_update_actions }
  end

  context "trying to edit as ECT" do
    let(:user) { create(:user, :early_career_teacher) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_edit_and_update_actions }
  end

  context "being a visitor" do
    let(:user) { nil }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_edit_and_update_actions }
  end
end
