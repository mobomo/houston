class SessionsController < ApplicationController
  def new
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(email: auth['info']['email']).first if !user

    if user
      attributes = {
        provider: auth['provider'], uid: auth['uid'].to_s,
        domain: auth['info']['email'].split('@').last, logged_in: DateTime.now
      }
      attributes.merge!(name: auth['info']['name']) unless user.name.present?
      user.update_attributes! attributes
    end

    if user
      session[:user_id] = user.id
      if user.email.blank?
        redirect_to edit_user_path(user), alert: "Please enter your email address."
      else
        redirect_to root_url, notice: 'Signed in'
      end
    else
      redirect_to signin_url, alert: "Unable to sign in, email #{auth['info']['email']} does not exist."
    end

  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'Signed out'
  end

  def failure
    redirect_to signin_url, alert: "Authentication error: #{params[:message].humanize}"
  end

end
