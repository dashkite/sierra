import { Authorization } from "@dashkite/http-headers"
import * as Runes from "@dashkite/runes-client"
import Credentials from "../credentials"

class Provider

  @make: ({ locator }) ->
    Object.assign ( new @ ), { locator: locator }

  @encode: ({ rune, nonce }) ->
    Authorization.format
      scheme: "rune"
      parameters: { rune, nonce }

  matches: ( query ) ->
    query.identity? && query.url? && query.method?

  get: ({ query }) ->
    { identity, url, method } = query
    { domain, name } = await @locator.decode url
    resources = [ name ]
    runes = []
    seen = new Set
    while resources.length > 0
      resource = resources.shift()
      if ( result = Runes.lookup { identity, domain, resource, method })?
        if !( seen.has result.credential.rune )
          seen.add result.credential.rune
          runes.push result.credential
          resources.push result.resources...
      else
        runes = []
        break
    if runes.length > 0
      Credentials.bundle ( runes.map @constructor.encode )
          
  store: ( authorization ) ->
    if authorization.scheme == "rune"
      Runes.store authorization.parameters
    else
      throw new Error "sierra: 
        scheme mismatch,
        got [ #{ authorization.scheme } ]
        expected [ rune ]"

export default Provider