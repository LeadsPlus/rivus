# encoding: UTF-8
class SourcesController < ApplicationController
  inherit_resources
  respond_to :json, :html

  def create
    create! do
      if url = resource.authorize_after_create?
        url
      else
        edit_source_path resource.id
      end
    end
  end

  def update
    update! { sources_url }
  end

  # Request authorization for a source by doing the OAuth dance.  This will
  # update the current source's authorizations regardless of their previous
  # value.
  #
  # GET /sources/:id/authorize
  def authorize
    if url = resource.authorize_url!
      redirect_to url
    else
      flash[:error] = "This source does not need remote authorization."
      redirect_to sources_path
    end
  end

  protected

  def begin_of_association_chain
    current_user
  end
end
