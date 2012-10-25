# encoding: UTF-8

class AuthorizationsController < ApplicationController
  before_filter :validate_type
  before_filter :validate_source

  # GET /auth/cb/:type
  def cb
    if source.configure_auth_data!(params)
      flash[:notice] = "Your source #{source.name} is ready!"
    else
      flash[:error] = "Could not configure the source #{source.name}! :("
    end
    redirect_to dashboard_url
  end

  protected

  # @return [Source]   The authorizing source...
  # @return [NilClass] Source not found
  #
  # FIXME
  #   The find method depends on the params[:type], this is Github specific (so far).
  def source
    @source ||= Source.where('auth_data.state' => params[:state]).one
  end

  # Source type must be known
  def validate_type
    unless Source.valid_type?(params[:type])
      flash[:error] = 'Received an unknown source type.'
      redirect_to root_url
    end
  end

  # Source must exist
  def validate_source
    unless source
      flash[:error] = 'Invalid authorization'
      redirect_to root_url
    end
  end
end
