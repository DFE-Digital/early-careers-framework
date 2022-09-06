# frozen_string_literal: true

RSpec.describe Admin::Participants::ValidationTasks, :with_default_schedules, type: :view_component do
  component { described_class.new profile: }

  context "for NPQ profile" do
    let!(:profile) { create :npq_participant_profile }

    ParticipantProfile::NPQ.validation_steps.each do |task|
      describe "#{task} validation task" do
        let(:t_scope) { "schools.participants.validations.npq.#{task}" }

        it { is_expected.to have_content t(:name, scope: t_scope) }
        it { is_expected.to have_link t(:link_text, scope: t_scope), href: validation_step_admin_participant_path(profile, task) }
      end
    end
  end
end
