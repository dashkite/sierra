import { Machine, Sync, $end } from "@dashkite/talos"
import Rune from "./rune"
import Credential from "./credential"


When =
  targetsRune: ( talos ) ->
    talos.context.type == "rune"


Run =
  noBuild: ( talos ) ->
    { type } = talos.context
    throw new Error "unable to build unrecognized credential type #{ type }"

  buildRune: ( talos ) ->
    { resource, options } = talos.context
    for current from Rune.find resource, options
      yield current
    if current.failure
      throw current.error
    talos.context.credentials = current.context.credentials 

  encodeCredentials: ( talos ) ->
    talos.context.credentials = Credential.encode talos.context.credentials


machine = Machine.make "sierra: build",
  start:
    buildRune: When.targetsRune
    default: "noBuild"
  noBuild: 
    run: Run.noBuild
    move: $end
  buildRune:
    run: Run.buildRune
    move: "encodeCredentials"
  encodeCredentials:
    run: Run.encodeCredentials
    move: $end


Build =
  start: ( context ) -> Sync.start machine, context
  

export default Build