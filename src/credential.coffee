import { Authorization } from "@dashkite/http-headers"
import JSON64 from "./json64"


Credential = 
  encode: ( credentials ) ->
    Authorization.format
      scheme: "credentials"
      token: JSON64.encode credentials


export default Credential