# frozen_string_literal: true

RSpec.describe Mail::DeliveryRecorder, :with_default_schedules do
  let(:mail) do
    Mail::Message.new(to: Faker::Internet.email, from: Faker::Internet.email, personalisation:)
  end

  let(:response) do
    instance_double(
      Notifications::Client::ResponseNotification,
      id: SecureRandom.uuid,
      template: {
        "id" => SecureRandom.uuid,
        "version" => rand(1..100),
      },
      content: {
        "from_email" => Faker::Internet.email,
      },
      uri: Faker::Lorem.words(number: 4).join("/"),
    )
  end

  let(:personalisation) do
    Array.new(rand(2..5)) { Faker::Lorem.words(number: 2) }.to_h.symbolize_keys
  end

  subject(:recorder) { described_class.new(enabled: true) }

  before do
    ActionMailer::Base.wrap_delivery_behavior(mail, :notify, api_key: "SomeKey")
    mail.delivery_method.response = response
    mail.original_to = mail.to
  end

  it "records the sent email into the database" do
    expect { recorder.delivered_email(mail) }.to change(Email, :count).by 1
  end

  context "when user exists with a matching email" do
    let!(:user) { create :user, email: mail.to.sample }

    it "associates email record with that user" do
      expect { recorder.delivered_email(mail) }
        .to change { Email.associated_with(user).count }.by 1
    end
  end

  context "with some other associated objects" do
    let(:object) { create %i[ect_participant_profile school school_cohort].sample }
    let(:name) { Faker::Lorem.words.join("_").to_sym }

    it "records the association between email and an object" do
      mail.associate_with(object, as: name)

      expect { recorder.delivered_email(mail) }
        .to change { Email.associated_with(object).count }.by 1
    end
  end

  context "with a tag" do
    let(:tag) { Faker::Lorem.word }

    it "records the tag on the email record" do
      mail.tag(tag)

      expect { recorder.delivered_email(mail) }
        .to change { Email.tagged_with(tag).count }.by 1
    end
  end

  context "when recorder is disabled" do
    subject(:recorder) { described_class.new(enabled: false) }

    it "does not record emails" do
      expect { recorder.delivered_email(mail) }.not_to change(Email, :count)
    end
  end

  context "when email has no personalisation header" do
    let(:mail) do
      Mail::Message.new(to: Faker::Internet.email, from: Faker::Internet.email)
    end

    it "records the sent email into the database" do
      expect { recorder.delivered_email(mail) }.to change(Email, :count).by 1
    end
  end
end
