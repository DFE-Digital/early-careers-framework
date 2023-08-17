# frozen_string_literal: true

RSpec.describe Admin::Schools::RelationshipComponent, type: :component do
  let(:school) { FactoryBot.create(:seed_school) }
  let(:school_cohort) { FactoryBot.create(:seed_school_cohort, :with_cohort, :with_appropriate_body, school:) }
  let(:relationship) { FactoryBot.create(:seed_partnership, :relationship, :valid, school:, cohort: school_cohort.cohort) }
  let(:superuser) { false }
  let(:participants) { nil }
  let(:kwargs) { { school:, school_cohort:, relationship:, superuser:, participants: } }
  subject { Admin::Schools::RelationshipComponent.new(**kwargs) }

  describe "rendering" do
    before { render_inline(subject) }

    it "renders a summary list within a summary card" do
      expect(rendered_content).to have_css("div.govuk-summary-card") do |card|
        expect(card).to have_css("dl.govuk-summary-list")
      end
    end

    it "has the lead provider's name as the card title" do
      expect(rendered_content).to have_css(".govuk-summary-card__title-wrapper", text: relationship.lead_provider.name)
    end

    it "has no challenge link when the user isn't a superuser" do
      expect(rendered_content).not_to have_content("Challenge")
    end

    context "when the user is a superuser" do
      let(:superuser) { true }

      it "has a challenge link when the user is a superuser" do
        expect(rendered_content).to have_content("Challenge")

        expected = "/admin/schools/#{school.slug}/partnerships/#{relationship.id}/challenge-partnership/new"
        expect(rendered_content).to have_link("Challenge", href: expected)
      end
    end

    describe "listing participants under this relationship" do
      let(:participants) { FactoryBot.create_list(:seed_ect_participant_profile, 3, :valid) }

      it "renders the participants in a list" do
        expect(rendered_content).to have_css("ul.govuk-list") do |list|
          expect(list).to have_css("li", count: participants.size)

          participants.each do |participant|
            expect(list).to have_link(participant.full_name, href: "/admin/participants/#{participant.id}")
          end
        end
      end
    end
  end
end
