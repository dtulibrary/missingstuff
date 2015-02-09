FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "email-#{srand}@test.com" }
    factory :admin do
      after(:build) do |user|
        def user.groups
          ["admin", "catalog"]
        end
      end
    end
  end
end
