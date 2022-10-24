# frozen_string_literal: true

RSpec.describe Admin::NPQ::Participants::ValidationTasks, :with_default_schedules, type: :component do
  let(:component) { described_class.new profile: }

  context "for NPQ profile" do
    let(:profile) { create :npq_participant_profile }

    ParticipantProfile::NPQ.validation_steps.each do |task|
      describe "#{task} validation task" do
        let(:t_scope) { "schools.participants.validations.npq.#{task}" }

        subject! { render_inline(component) }

        it { is_expected.to have_content I18n.t(:name, scope: t_scope) }
        it { is_expected.to have_link I18n.t(:link_text, scope: t_scope), href: validation_step_admin_participant_path(profile, task) }
      end
    end
  end
end
