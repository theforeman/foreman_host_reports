FactoryBot.define do
  factory :host_report do
    host
    reported_at { Time.now.utc }
    status { 0 }
    body { 'report data' }
  end
end
