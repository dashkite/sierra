import { Authorization } from "@dashkite/http-headers"
import * as Runes from "@dashkite/runes-client"
import Credentials from "../credentials"

class Provider

  @make: ({ provider }) ->
    Object.assign ( new @ ), { provider }

  @encode: ({ rune, nonce }) ->
    Authorization.format
      scheme: "rune"
      parameters: { rune, nonce }

  find: ({ request, identity }) ->
    resource = await @provider.decode request.url
    resources = [ resource ]
    runes = []
    seen = new Set
    while resources.length > 0
      resource = resources.shift()
      if ( result = Runes.lookup { identity, resource... })?
        if !( seen.has result.credential.rune )
          seen.add result.credential.rune
          runes.push result.credential
          resources.push result.resources...
      else
        runes = []
        break
    if runes.length > 0
      Credentials.encode ( runes.map @constructor.encode )
          
  store: ( authorization ) ->
    if authorization.scheme == "rune"
      Runes.store authorization.parameters
    else
      throw new Error "sierra: 
        scheme mismatch,
        got [ #{ authorization.scheme } ]
        expected [ rune ]"

export default Provider