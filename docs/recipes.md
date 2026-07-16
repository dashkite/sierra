# Usage Guides

## Initializing the registry and providers

This recipe demonstrates how to initialize the registry and configure authentication providers. Sierra enables this by providing a central repository that coordinates various accessor pattern strategies.

```coffeescript
import Registry from "@dashkite/sierra"
import RuneProvider from "@dashkite/sierra/rune"
import CredentialsProvider from "@dashkite/sierra/credentials"

# assume a locator instance is available from the environment
registry = Registry.make()

runeProvider = RuneProvider.make { locator }
credentialsProvider = CredentialsProvider.make registry

registry.add "rune", runeProvider
registry.add "credentials", credentialsProvider
```

1. Initialize a new `Registry` instance to serve as the central coordinator.
2. Initialize specific providers, such as the `RuneProvider` (passing required dependencies like a locator) and the `CredentialsProvider` (passing the registry itself).
3. Call `add` on the registry to associate scheme names (like `"rune"` and `"credentials"`) with their respective provider instances.

## Generating an authorization header

This recipe demonstrates how to automatically generate a valid authorization header for an outbound HTTP request. The registry streamlines this process by matching challenge specifiers to the correct provider and formatting the resulting credential.

```coffeescript
# assuming the registry is initialized and populated
specifier = 
  challenge: 
    scheme: "rune"
  query: 
    identity: "alice"
    url: "https://example.com/api"
    method: "GET"

header = await registry.authorization specifier
```

1. Define a specifier containing a `challenge` and `query` object that represents the access requirements.
2. Pass the specifier to the `authorization` method on the registry.
3. The registry evaluates the specifier, invokes the matching provider's `get` method, and formats the physical credential into a standard HTTP header string.

## Resolving multiple authentication challenges

This recipe demonstrates how to interrogate a list of authentication challenges and manually retrieve a credential. Sierra enables developers to filter challenges and query the appropriate provider directly when handling complex, secure server responses.

```coffeescript
# assuming the registry is initialized
challenges = [ { scheme: "Basic" }, { scheme: "rune" } ]

supported = registry.supported challenges

if supported.length > 0
  provider = registry.query 
    challenge: supported[0]
    query: { identity: "alice", url: "https://example.com/api", method: "GET" }
  
  credential = await registry.get 
    challenge: supported[0]
    query: { identity: "alice", url: "https://example.com/api", method: "GET" }
```

1. Pass an array of received challenges to the `supported` method to filter out schemes the registry cannot handle.
2. Pass a supported challenge and a context query to the `query` method to identify the specific provider instance, verifying it matches the criteria.
3. Call the `get` method on the registry with the same challenge and query to retrieve the physical credential object directly from the provider.

## Bundling and storing compound credentials

This recipe demonstrates how to transmit and store multiple distinct credentials simultaneously. Sierra enables this through the `CredentialsProvider`, which safely bundles arrays of credentials using JSON64 and stores them by dispatching them back to their native providers.

```coffeescript
import CredentialsProvider from "@dashkite/sierra/credentials"

# assume registry is initialized and populated with a rune provider
credentials = [
  { scheme: "rune", parameters: { rune: "example-rune-1", nonce: "abc" } }
  { scheme: "rune", parameters: { rune: "example-rune-2", nonce: "xyz" } }
]

header = CredentialsProvider.encode credentials
parameters = CredentialsProvider.bundle credentials

authorization = { scheme: "credentials", token: parameters.token }

credentialsProvider = registry.query { challenge: { scheme: "credentials" }, query: {} }
credentialsProvider.store authorization
```

1. Construct an array of individual credentials containing their respective schemes and parameters.
2. Call `encode` to generate an immediate Authorization header, or call `bundle` to safely wrap the array into a JSON64 encoded parameter object.
3. Construct an authorization payload using the bundled token.
4. Pass the authorization payload to the `store` method on the credentials provider, which decodes the token and delegates the persistence of each embedded credential to its respective provider in the registry.
