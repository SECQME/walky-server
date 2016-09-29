# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tip do
    description "Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Integer posuere erat a ante venenatis dapibus posuere velitas."
    location "POINT(-87.7268804 41.8780091)"
    username "john_doe"
    user_id "60-123456789"
    archived false
    is_time_sensitive false
    expiry_date (DateTime.now+3)
  end

  trait :tip_without_description do
    description nil
  end

  trait :tip_without_location do
    location nil
  end

  trait :tip_without_username do
    username nil
  end

  trait :tip_without_user_id do
    user_id nil
  end
end