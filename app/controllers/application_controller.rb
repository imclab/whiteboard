class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :boxed
  before_filter :require_login

  def require_login
    mapper = IpToStandupMapper.new
    current_ip = request.env['HTTP_X_FORWARDED_FOR']

    redirect_to '/auth/google_apps' unless session[:logged_in] || mapper.authorized?(ip_address: current_ip)
  end

  # Adds an outer container element around any yielded HTML.
  # TODO: Get rid of this. We shouldn't toggle an HTML wrapping in the controller.
  def boxed
    @boxed = true
  end
end
