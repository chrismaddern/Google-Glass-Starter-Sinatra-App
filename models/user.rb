class User < ActiveRecord::Base

attr_accessible :token, :email, :expires_in, :issued_at,
                :refresh_token, :disabled, :access_token,
                :service_token, :service_token_expires_at

def self.user_with_token (user_id)
  usrs = User.where('token = ?', user_id)
  if (usrs.count(:id) > 0)
    usrs.first
  else
    nil
  end
end

end