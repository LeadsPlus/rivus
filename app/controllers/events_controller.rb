# encoding: UTF-8
class EventsController < ApplicationController
  inherit_resources
  respond_to :json

  protected

  def begin_of_association_chain
    current_user
  end
end
