FactoryGirl.define do
  factory :book do
    title ["Kind of Blue"]

    # Sets depositor metadata (required)
    ignore do
      user { FactoryGirl.create(:user) }
    end
    before(:create) do |work, evaluator|
      work.attributes= {person: [{first_name:"Miles", last_name:"Davis", role:"Trumpet"},{first_name:"Julian \"cannonball\"", last_name:"Adderly", role:"Alto saxophone"}] }
      work.apply_depositor_metadata(evaluator.user.user_key)
    end
  end
end