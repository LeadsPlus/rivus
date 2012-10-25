class Rivus.Models.Source extends Backbone.Model
  url: ->
    if @id
      "/sources/#{ @id }"
    else
      "/sources"

class Rivus.Collections.Source extends Backbone.Model
  model: Rivus.Models.Source
  url: '/sources'
