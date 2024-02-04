import { Machine, Sync, $end } from "@dashkite/talos"
import { Authorization } from "@dashkite/http-headers"
import * as Runes from "@dashkite/runes-client"


When =
  moreResources: ( talos ) ->
    talos.context.resources.length > 0


Run =
  getEmail: ( talos ) ->
    identity = localStorage.getItem "email"
    if !identity?
      throw new Error "no email found in localStorage"
    talos.context.identity = identity

  findRune: ( talos ) ->
    { identity, resources, options } = talos.context
    { domain, name, method } = resources.shift()
    rune = Runes.lookup { identity, domain, resource: name, method }, options
    if !rune?.credential?
      throw new Error "no matching grant"
    talos.context.rune = rune

  encodeRune: ( talos ) ->
    credential = Rune.encode talos.context.rune
    talos.context.credentials.push credential    

  readResources: ( talos ) ->
    resources = talos.context.rune.resources ? []
    talos.context.resources.push resources...

  deduplicate: ( talos ) ->
    credentials = Array.from ( new Set talos.context.credentials )
    talos.context.credentials = credentials


machine = Machine.make "sierra: find runes",
  start: "get email from local storage",
  
  "get email from local storage":
    run: Run.getEmail,
    move: "find rune"
  
  "find rune":
    run: Run.findRune
    move: "encode this rune"
  
  "encode this rune":
    run: Run.encodeRune
    move: "crawl graph for additional runes"

  "crawl graph for additional runes":
    run: Run.readResources
    move: "confirm graph crawl is complete"
  
  "confirm graph crawl is complete":
    "find rune": When.moreResources
    default: "deduplicate found runes"
  
  "deduplicate found runes":
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