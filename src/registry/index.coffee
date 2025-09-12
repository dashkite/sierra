import { metaclass } from "@dashkite/joy/metaclass"
class Registry extends metaclass()

  @make: ->
    Object.assign ( new @ ), registry: {}

  @getters
    schemes: -> new Set Object.keys @registry

  add: ( scheme, provider ) ->
    @registry[ scheme ] = provider
    
  get: ( scheme ) ->
    if ( provider = @registry[ scheme ])?
      provider
    else
      throw new Error "sierra: 
        missing provider for 
        [ #{ scheme  } ]"

  supported: ( schemes ) ->
    @schemes.intersection new Set schemes

      
export default Registry