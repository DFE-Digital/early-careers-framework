# frozen_string_literal: true

class MyMailer < ApplicationMailer
  attr_reader :from, :to, :user_name

  def hello
    @from = params[:our_email]
    @user_name = params[:user_name]
    @to = params[:user_email]

    mail(from:, to:, personalisation: { subject: "Hi" }) do |format|
      format.text { render plain: "Hello #{user_name}" }
    end
  end
end

class MyOtherMailer < ApplicationMailer
  attr_reader :from, :to, :user_name

  def hello
    @from = params[:our_email]
    @user_name = params[:user_name]
    @to = params[:user_email]

    mail(from:, to:, personalisation: { age: "25" }) do |format|
      format.text { render plain: "Hello #{user_name}" }
    end
  end
end

RSpec.describe Mail::Personalisation, type: :mailer do
  let(:subject_value) { "Hi" }
  let(:our_email) { Faker::Internet.email }
  let(:user_name) { Faker::Name.name }
  let(:user_email) { Faker::Internet.email }
  let(:mail) { MyMailer.with(our_email:, user_name:, user_email:).hello.deliver_now }

  context "testing environment" do
    let(:subject_tags) { Mail::Notify::Personalisation::BLANK }

    it "adds a blank :subject_tags entry to the personalisation header of emails sent" do
      expect(mail.from).to eq([our_email])
      expect(mail.to).to eq([user_email])
      expect(mail["personalisation"].unparsed_value).to eq({ subject: subject_value, subject_tags: })
      expect(mail.body.encoded).to match("Hello #{user_name}")
    end
  end

  context "production environment" do
    let(:subject_tags) { Mail::Notify::Personalisation::BLANK }

    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
    end

    it "adds a blank :subject_tags entry to the personalisation header of emails sent" do
      expect(mail.from).to eq([our_email])
      expect(mail.to).to eq([user_email])
      expect(mail["personalisation"].unparsed_value).to eq({ subject: subject_value, subject_tags: })
      expect(mail.body.encoded).to match("Hello #{user_name}")
    end
  end

  context "environments other than testing or production" do
    let(:environment_name) { "staging" }
    let(:subject_tags) { "[#{environment_name} to:#{mail.to.join(',')}]  " }

    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment_name))
    end

    it "do not modify email addresses or body" do
      expect(mail.from).to eq([our_email])
      expect(mail.to).to eq([user_email])
      expect(mail.body.encoded).to match("Hello #{user_name}")
    end

    it "adds a :subject_tags entry to the personalisation header of emails sent including environment name and destination addresses" do
      expect(mail["personalisation"].unparsed_value).to include(subject_tags:)
    end

    it "prepends the subject_tags value in the :subject entry in the personalisation header of emails sent" do
      expect(mail["personalisation"].unparsed_value).to include(subject: [subject_tags, subject_value].join)
    end

    context "when no subject field exists in the personalisation header" do
      let(:mail) { MyOtherMailer.with(our_email:, user_name:, user_email:).hello.deliver_now }

      it "do not add a :subject entry into the personalisation header of emails sent" do
        expect(mail["personalisation"].unparsed_value).not_to include(:subject)
      end
    end
  end
end
