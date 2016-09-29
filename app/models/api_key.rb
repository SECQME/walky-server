class ApiKey < ActiveRecord::Base
  before_create :generate_authentication_token!
  belongs_to :user

  private
    def generate_authentication_token!
      begin
        self.access_token = SecureRandom.hex
      end while self.class.exists?(access_token: access_token)
    end
end
