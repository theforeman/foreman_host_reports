FactoryBot.define do
  factory :host_report do
    host
    sequence(:proxy) { |n| FactoryBot.create(:smart_proxy, url: "http://proxy#{n}.example.com", features: [FactoryBot.create(:feature, name: 'Reports')]) }
    reported_at { Time.now.utc }
    change { 0 }
    nochange { 0 }
    failure { 0 }
    body { '{}' }
  end

  trait :puppet_format do
    format { 'puppet' }
  end

  trait :ansible_format do
    format { 'ansible' }
  end

  trait :with_failure do
    failure { 1 }
  end

  trait :with_change do
    change { 1 }
  end

  trait :with_nochange do
    nochange { 1 }
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
