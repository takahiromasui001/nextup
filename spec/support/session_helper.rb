module SessionHelper
  def login_as(user)
    post '/auth/google_oauth2/callback', env: {
      'omniauth.auth' => OmniAuth::AuthHash.new(
        provider: user.provider,
        uid: user.uid,
        info: { email: user.email, name: user.name }
      )
    }
  end
end
