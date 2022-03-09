FactoryBot.define do
  factory :statement, class: "Finance::Statement" do
    name          { Time.zone.today.strftime "%B %Y" }
    deadline_date { (Time.zone.today - 1.month).end_of_month }
    payment_date  { Time.zone.today.end_of_month }

    factory :npq_statement, class: "Finance::Statement::NPQ"
  end
end
