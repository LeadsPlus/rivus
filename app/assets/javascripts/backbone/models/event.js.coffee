class Rivus.Models.Event extends Backbone.Model
  url: ->
    if @id
      "/events/#{ @id }"
    else
      "/events"

class Rivus.Collections.Event extends Backbone.Model
  model: Rivus.Models.Event
  url: '/events'
