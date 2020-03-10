# frozen_string_literal: true
class ApplicationController < ActionController::Base
  before_action :authorize
  around_action :switch_locale

  protected

  def authorize
    unless User.find_by(id: session[:user_id])
      redirect_to(login_url, notice: I18n.t('messages.session.please_login'))
    end
  end

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options(options = {})
    if I18n.default_locale != I18n.locale
      { locale: I18n.locale }.merge(options)
    else
      { locale: nil }.merge(options)
    end
  end
end
