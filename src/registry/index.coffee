import { metaclass } from "@dashkite/joy/metaclass"
import { Authorization } from "@dashkite/http-headers"
import Generic from "@dashkite/generic"
class Registry extends metaclass()

  @make: ->
    Object.assign ( new @ ), registry: []

  @getters
    schemes: -> new Set @registry.map ({ scheme }) -> scheme

  add: ( scheme, provider ) ->
    @registry.push { scheme, provider... }
    
  supported: ( challenges ) ->
    schemes = @schemes
    challenges.filter ( challenge ) ->
      schemes.has challenge.scheme

  query: ({ challenge, query }) ->
    @registry.find ( provider ) ->
      ( provider.scheme == challenge.scheme ) && 
        ( provider.matches query )
        
  get: ({ challenge, query }) ->
    if ( provider = @query { challenge, query })?
      provider.get { challenge, query }
      
  authorization: do ->
    ( Generic.make "Registry.authorization" )

      .define [ Object ], ( specifier ) ->
        if ( credential = @get specifier )?
          Authorization.format credential

      .define [ Array ], ( specifiers ) ->
        for specifier in specifiers
          if ( authorization = @authorization specifier )?
            break
        authorization


export default Registry
