import { Machine, Sync, $end } from "@dashkite/talos"
import { Authorization } from "@dashkite/http-headers"
import * as Runes from "@dashkite/runes-client"


When =
  moreResources: ( talos ) ->
    talos.context.resources.length > 0


Run =
  getIdentity: ( talos ) ->
    identity = localStorage.getItem "identity"
    if !identity?
      throw new Error "no identity found in localStorage"
    talos.context.identity = identity

  findRune: ( talos ) ->
    { identity, resources, options } = talos.context
    { domain, name, method } = resources.shift()
    console.log { identity, domain, resource: name, method  }
    rune = Runes.lookup { identity, domain, resource: name, method }, options
    if !rune?.credential?
      throw new Error "no matching grant"
    talos.context.rune = rune
    
  readResources: ( talos ) ->
    resources = talos.context.rune.resources ? []
    talos.context.resources.push resources...
   
  encodeRune: ( talos ) ->
    credential = Rune.encode talos.context.rune
    talos.context.credentials.push credential

  deduplicate: ( talos ) ->
    credentials = Array.from ( new Set talos.context.credentials )
    talos.context.credentials = credentials


machine = Machine.make "find runes",
  start: "getIdentity",
  getIdentity:
    run: Run.getIdentity,
    move: "findRune"
  findRune:
    run: Run.findRune
    move: "readResources"
  readResources:
    run: Run.readResources
    move: "encodeRune"
  encodeRune:
    run: Run.encodeRune
    move: "checkDone"
  checkDone:
    findRune: When.moreResources
    default: "deduplicate"
  deduplicate:
    run: Run.deduplicate
    move: $end


Rune = 
  find: ( resource, options ) ->
    Sync.start machine,
      credentials: []
      resources: [ resource ]
      options: options

  encode: ( rune ) ->
    Authorization.format
      scheme: "rune"
      parameters: rune.credential
      

export default Rune