import { convert } from "@dashkite/bake"

JSON64 =

  encode: (value) ->
    Confidential.convert
      from: "utf8"
      to: "base64"
      JSON.stringify value
  
  decode: (value) ->
    converted = Confidential.convert
      from: "base64"
      to: "utf8"
      value
    JSON.parse converted


export default JSON64