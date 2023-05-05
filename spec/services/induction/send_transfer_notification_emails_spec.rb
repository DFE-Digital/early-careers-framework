# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Induction::SendTransferNotificationEmails) do
  subject { Induction::SendTransferNotificationEmails.new(**kwargs) }

  let(:provider_mailer) { double(ActionMailer::MessageDelivery, deliver_later: true) }
  let(:participant_mailer) { double(ActionMailer::MessageDelivery, deliver_later: true) }

  before do
    allow(ParticipantTransferMailer).to receive(template).and_return(provider_mailer)
    allow(ParticipantTransferMailer).to receive(:participant_transfer_in_notification).and_return(participant_mailer)
  end

  shared_examples "notifying the participant" do
    it "sends a 'particicpant transfter in notification' email to the participant" do
      expect {
        subject.call
      }.to have_enqueued_mail(ParticipantTransferMailer, :participant_transfer_in_notification)
        .with(
          params: {
            induction_record:,
          },
          args: [],
        ).once
    end
  end

  # defaults
  let(:template) { :provider_transfer_in_notification }
  let(:induction_record) { create(:induction_record) }
  let(:was_withdrawn_participant) { false }
  let(:same_delivery_partner) { false }
  let(:same_provider) { false }
  let(:switch_to_schools_programme) { false }
  let(:lead_provider_profiles_in) { create_list(:lead_provider_profile, 3) }
  let(:lead_provider_profiles_out) { create_list(:lead_provider_profile, 2) }

  let(:kwargs) do
    {
      induction_record:,
      was_withdrawn_participant:,
      same_delivery_partner:,
      same_provider:,
      switch_to_schools_programme:,
      lead_provider_profiles_in:,
      lead_provider_profiles_out:,
    }
  end

  %i[
    induction_record
    was_withdrawn_participant
    same_delivery_partner
    same_provider
    switch_to_schools_programme
    lead_provider_profiles_in
    lead_provider_profiles_out
    was_withdrawn_participant?
    same_delivery_partner?
    same_provider?
    switch_to_schools_programme?
  ].each { |a| it { is_expected.to respond_to(a) } }

  context "when the participant has been withdrawn" do
    let(:template) { :provider_transfer_in_notification }
    let(:was_withdrawn_participant) { true }

    it "sends 'provider transfer in notification' emails to the current lead provider profiles " do
      lead_provider_profiles_in.each do |lead_provider_profile|
        expect {
          subject.call
        }.to have_enqueued_mail(ParticipantTransferMailer, template)
          .with(
            params: {
              induction_record:,
              lead_provider_profile:,
            },
            args: [],
          ).once
      end
    end
  end

  context "when the lead provider and delivery partner match" do
    let(:template) { :provider_existing_school_transfer_notification }
    let(:same_delivery_partner) { true }
    let(:same_provider) { true }

    it "sends 'provider transfer in notification' emails to the current lead provider profiles " do
      lead_provider_profiles_in.each do |lead_provider_profile|
        expect {
          subject.call
        }.to have_enqueued_mail(ParticipantTransferMailer, template)
          .with(
            params: {
              induction_record:,
              lead_provider_profile:,
            },
            args: [],
          ).once
      end
    end

    include_examples "notifying the participant"
  end

  context "when it's a switch to schools programme" do
    let(:template) { :provider_existing_school_transfer_notification }
    let(:switch_to_schools_programme) { true }

    describe "in" do
      let(:template) { :provider_transfer_in_notification }

      it "sends 'provider transfer in notification' emails to the current lead provider profiles " do
        lead_provider_profiles_in.each do |lead_provider_profile|
          expect {
            subject.call
          }.to have_enqueued_mail(ParticipantTransferMailer, template)
            .with(
              params: {
                induction_record:,
                lead_provider_profile:,
              },
              args: [],
            ).once
        end
      end
    end

    describe "out" do
      let(:template) { :provider_transfer_out_notification }

      it "sends 'provider transfer out notification' emails to the target lead provider profiles " do
        lead_provider_profiles_out.each do |lead_provider_profile|
          expect {
            subject.call
          }.to have_enqueued_mail(ParticipantTransferMailer, template)
            .with(
              params: {
                induction_record:,
                lead_provider_profile:,
              },
              args: [],
            ).once
        end
      end
    end

    include_examples "notifying the participant"
  end

  context "when it's a new school transfer" do
    let(:template) { :provider_new_school_transfer_notification }

    it "sends 'provider transfer in notification' emails to the current lead provider profiles " do
      lead_provider_profiles_out.each do |lead_provider_profile|
        expect {
          subject.call
        }.to have_enqueued_mail(ParticipantTransferMailer, template)
          .with(
            params: {
              induction_record:,
              lead_provider_profile:,
            },
            args: [],
          ).once
      end
    end

    include_examples "notifying the participant"
  end
end
