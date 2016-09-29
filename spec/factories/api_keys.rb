# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_key do
    user nil
    access_token "MyString"
    deleted_at "2015-12-09 13:22:05"
  end
end
