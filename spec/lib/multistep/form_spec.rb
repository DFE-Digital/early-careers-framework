# frozen_string_literal: true

RSpec.describe Multistep::Form do
  let(:form_class) do
    Class.new do
      include ActiveModel::Model
      include Multistep::Form

      attribute :generic_attribute

      step :first_step do
        attribute :first_step_attribute

        validates :first_step_attribute, presence: true

        next_step do
          first_step_attribute.is_a?(Numeric) ? :second_step : :interim_step
        end
      end

      step :interim_step do
        next_step :final_step
      end

      step :second_step do
        attribute :second_step_attribute

        validate :second_step_attribute_must_be_a_number
      end

      step :final_step

      def second_step_attribute_must_be_a_number
        errors.add(:second_step_attribute, :not_a_number) unless second_step_attribute.is_a? Numeric
      end
    end
  end

  subject(:form) { form_class.new }

  it "aggregates all the attributes from all the steps" do
    expect(subject.attributes).to include("generic_attribute", "first_step_attribute", "second_step_attribute")
  end

  describe "#next_step" do
    context "when no step has been completed" do
      it "returns first defined step as the next step" do
        expect(form.next_step).to be :first_step
      end
    end

    context "when at least one step has been completed" do
      before { form.record_completed_step completed_step }

      context "and that step defines next step with a block" do
        let(:completed_step) { :first_step }

        it "returns the value of the block executed in the context of the form" do
          form.first_step_attribute = 1
          expect(form.next_step).to be :second_step

          form.first_step_attribute = :hello
          expect(form.next_step).to be :interim_step
        end
      end

      context "and that step defines next step as a symbol" do
        let(:completed_step) { :interim_step }

        it "returns the defined next_step" do
          expect(form.next_step).to be :final_step
        end
      end
    end
  end

  describe "#previous_step" do
    context "when no step has been completed" do
      it "returns nil" do
        expect(form.previous_step).to be nil
      end
    end

    context "when some steps has been completed" do
      before do
        form.record_completed_step(:first_step)
        form.record_completed_step(:second_step)
      end

      it "returns most recent step when no `from` argument is given" do
        expect(form.previous_step).to be :second_step
      end

      it "returns most recent step before given `from` argument" do
        expect(form.previous_step(from: :second_step)).to be :first_step
      end
    end
  end

  describe "#record_completed_step" do
    before do
      form.record_completed_step(:first_step)
      form.record_completed_step(:interim_step)
      form.record_completed_step(:second_step)
    end

    context "when recording given step for the first time" do
      it "adds the step to completed steps list" do
        expect { form.record_completed_step :final_step }
          .to change { form.completed_steps.dup }.by [:final_step]
      end
    end

    context "when re-recording already completed step" do
      it "trims the completed_steps back to that step" do
        expect { form.record_completed_step :interim_step }
          .to change { form.completed_steps.dup }.to %i[first_step interim_step]
      end
    end
  end

  describe "validations" do
    it "scopes validation to the step they're defined in" do
      form.first_step_attribute = "anything"

      expect(form.valid?(:first_step)).to be true
      expect(form.valid?(:second_step)).to be false
    end

    it "runs all the validation when called without the context" do
      expect(form).not_to be_valid

      form.first_step_attribute = "anything"
      form.second_step_attribute = 1

      expect(form).to be_valid
    end
  end
end
