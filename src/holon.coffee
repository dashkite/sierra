When = 
  result: ( talos ) ->
    (talos.name == "sierra: build") && talos.success

Get =
  credentials: ( talos ) ->
    talos.context.credentials

export { When, Get }