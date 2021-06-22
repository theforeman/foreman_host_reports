FactoryBot.define do
  factory :host_report do
    host
    reported_at { Time.now.utc }
    status { 0 }
    body { 'report data' }
  end

  factory :report_keyword do
    sequence(:name) { |n| "Keyword-#{n}" }
  end
end
