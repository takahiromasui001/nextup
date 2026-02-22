class SessionsController < ApplicationController
  skip_before_action :require_login

  def new
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.find_or_create_by(provider: auth['provider'], uid: auth['uid']) do |u|
      u.email = auth['info']['email']
      u.name = auth['info']['name']
    end
    user.update(email: auth['info']['email'], name: auth['info']['name'])

    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end
end
