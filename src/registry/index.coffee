class Registry

  @make: ->
    Object.assign ( new @ ), registry: {}

  add: ( scheme, provider ) ->
    @registry[ scheme ] = provider
    
  get: ( scheme ) ->
    if ( provider = @registry[ scheme ])?
      provider
    else
      throw new Error "sierra: 
        missing provider for 
        [ #{ scheme  } ]"

export default Registry