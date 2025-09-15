import { Authorization } from "@dashkite/http-headers"
import JSON64 from "./json64"

class Provider

  @make: ( registry ) ->
    Object.assign ( new @ ), { registry }

  @encode: ( credentials ) ->
    Authorization.format @bundle credentials

  @bundle: ( credentials ) ->
    scheme: "credentials"
    token: JSON64.encode credentials

  matches: -> false

  get: ->

  store: ( authorization ) ->
    if authorization.scheme == "credentials"
      credentials = JSON64.decode authorization.token
      for credential in credentials
        registry
          .get credential.scheme 
          .store credential
    else
      throw new Error "sierra: 
        scheme mismatch,
        got [ #{ authorization.scheme } ]
        expected [ credentials ]"

export default Provider