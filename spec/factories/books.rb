FactoryGirl.define do
  factory :book do

    # Sets depositor metadata (required)
    ignore do
      user { FactoryGirl.create(:user) }
    end
    before(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :kind_of_blue do
      title ["Kind of Blue"]
      before(:create) do |work, evaluator|
        work.attributes= {person: [{first_name:"Miles", last_name:"Davis", role:"Trumpet"},{first_name:"Julian \"cannonball\"", last_name:"Adderly", role:"Alto saxophone"}] }
      end
    end
    factory :theory_of_moral_sentiments do
      title ["The Theory of Moral Sentiments"]
      description "Provides the ethical, philosophical, psychological, and methodological underpinnings to Smith's later works, including The Wealth of Nations (1776), Essays on Philosophical Subjects (1795), and Lectures on Justice, Police, Revenue, and Arms (1763) (first published in 1896)."
      publisher ["A. Kincaid and J. Bell, in Edinburgh"]
      subject ["Morality", "Human nature"]
      publication_date "on or before 12 April 1759"

      before(:create) do |work, evaluator|
        work.attributes= {person: [{first_name:"Adam", last_name:"Smith", role:"author"}] }
      end
    end

  end


end