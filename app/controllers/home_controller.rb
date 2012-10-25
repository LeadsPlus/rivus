class HomeController < ApplicationController
  def index
    return redirect_to dashboard_url if user_signed_in?
    render
  end
end
