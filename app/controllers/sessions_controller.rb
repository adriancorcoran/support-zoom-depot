# frozen_string_literal: true
class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
    user = User.find_by(name: params[:name])
    # if user.try(:authenticate, params[:password]) //  old skool way
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to(admin_url)
    else
      flash[:error] = I18n.t('messages.session.invalid_login')
      redirect_to(login_url)
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to(login_url, notice: I18n.t('messages.session.logged_out'))
  end
end
