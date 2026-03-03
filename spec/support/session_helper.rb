module SessionHelper
  def login_as(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: { email: user.email, name: user.name }
    )
    if respond_to?(:visit)
      visit '/auth/google_oauth2/callback'
    else
      get '/auth/google_oauth2/callback'
    end
  end
end
