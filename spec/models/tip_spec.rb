require 'spec_helper'

describe Tip, type: :model do
  let(:tip) { build(:tip) }

  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:location) }
  # it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:archived) }
  it { is_expected.to respond_to(:is_time_sensitive) }
  it { is_expected.to respond_to(:expiry_date) }
  it { is_expected.to respond_to(:created_at) }

  # it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:location) }

  it "should have an expiry_date if marked as time sensitive" do
  end

  it "must be archived after expiry_date has passed" do
  end

  it "must be archived automatically after one month" do
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
