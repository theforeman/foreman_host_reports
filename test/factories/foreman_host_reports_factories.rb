FactoryBot.define do
  factory :host_report do
    host
    reported_at { Time.now.utc }
    change { 0 }
    nochange { 0 }
    failure { 0 }
    body { 'report data' }
  end

  trait :with_keyword do
    transient do
      name { 'HasError' }
    end
    after(:build) do |report, evaluator|
      report.report_keyword_ids = [FactoryBot.create(:report_keyword, name: evaluator.name).id]
    end
  end

  factory :report_keyword do
    sequence(:name) { |n| "Keyword-#{n}" }
  end
end
