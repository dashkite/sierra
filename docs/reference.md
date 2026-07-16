# Reference

This document provides the API reference for the Sierra library.

## Core Architecture

Sierra implements the Accessor Pattern to manage security credentials efficiently. The system relies on two primary interfaces: the **Registry** and the **Provider**.

The **Registry** acts as the central coordinator. Libraries like Sublime or other HTTP clients interact with the Registry to request authorization headers without needing to understand how those credentials are fundamentally stored or retrieved. 

A **Provider** is a specific accessor pattern strategy (such as the `RuneProvider` or `CredentialsProvider`). Providers are registered with the Registry and handle the physical retrieval, formatting, and storage of credentials for their specific authentication scheme.

## Registry

The Registry coordinates the matching of authorization challenges with the appropriate provider strategy.

### make
$make: \to registry$

Initializes a new Registry instance. The Registry maintains an internal list of specific providers, allowing developers to inject different credential access strategies dynamically.

```coffeescript
import Registry from "@dashkite/sierra"
import assert from "@dashkite/assert"

registry = Registry.make()
assert registry?
```

### add
$add: scheme, provider \to \emptyset$

Registers a new provider for a specific authentication scheme. By adding providers, developers teach the registry how to handle different types of authorization challenges.

```coffeescript
registry.add "rune", runeProvider
assert registry.schemes.has "rune"
```

### supported
$supported: challenges \to schemes$

Evaluates an array of challenge objects (typically parsed from a `WWW-Authenticate` header) and returns the subset of challenges that the current registry knows how to fulfill.

```coffeescript
supportedChallenges = registry.supported [ { scheme: "rune" } ]
assert.equal supportedChallenges.length, 1
```

### query
$query: { challenge, query } \to provider$

Iterates through the registered providers to identify the correct strategy for fulfilling a specific authorization request. It evaluates both the required authentication scheme and the contextual query parameters to ensure the provider can accurately resolve the physical credential.

```coffeescript
# assuming the registry has a rune provider
provider = registry.query { challenge: { scheme: "rune" }, query: { method: "GET", url: "https://example.com", identity: "alice" } }
assert.equal provider.scheme, "rune"
```

### get
$get: { challenge, query } \to credential$

Delegates credential retrieval to the specific provider that matches the requested challenge and query. This method seamlessly bridges the logical request to the physical accessor pattern.

```coffeescript
credential = await registry.get { challenge: { scheme: "rune" }, query: { method: "GET", url: "https://example.com", identity: "alice" } }
assert credential?
```

### authorization
$authorization: specifier \to header$
$authorization: [specifiers] \to header$

Generates a completely formatted authorization header. This method utilizes DashKite Generic to accept either a single specifier object or an array of specifiers. When provided an array, it evaluates them sequentially and returns the header for the first successful resolution.

```coffeescript
header = await registry.authorization { challenge: { scheme: "rune" }, query: { method: "GET", url: "https://example.com", identity: "alice" } }
assert.equal (typeof header), "string"
```

## Credentials Provider

The Credentials Provider manages compound credentials, allowing multiple distinct authorization elements to be bundled together within a single HTTP header using JSON64 encoding.

### make
$make: registry \to provider$

Initializes a new credentials provider. It requires a reference to the active registry so that it can dispatch individual credentials to their respective providers during storage operations.

```coffeescript
import CredentialsProvider from "@dashkite/sierra/credentials"
import assert from "@dashkite/assert"

provider = CredentialsProvider.make registry
assert provider?
```

### encode
$encode: credentials \to header$

Formats an array of logical credentials into a standard Authorization header string, utilizing the `credentials` scheme.

```coffeescript
header = CredentialsProvider.encode [ { scheme: "custom", token: "xyz" } ]
assert.equal (typeof header), "string"
```

### bundle
$bundle: credentials \to parameters$

Transforms an array of credentials into a parameter object by encoding the array securely as a JSON64 string. This prepares the data for transport.

```coffeescript
parameters = CredentialsProvider.bundle [ { scheme: "custom", token: "xyz" } ]
assert parameters.token?
```

### store
$store: authorization \to \emptyset$

Parses an incoming authorization structure, decodes the bundled token, and iterates through each embedded credential. It delegates the persistence of each credential back to the registry.

```coffeescript
authorization = { scheme: "credentials", token: "eyJzY2hlbWUiOiJjdXN0b20ifQ==" }
provider.store authorization
assert true # verify successful completion without errors
```

## Rune Provider

The Rune Provider acts as the specialized bridge to the `runes` and `runes-client` libraries, handling the physical validation and retrieval of cryptographic runes.

### make
$make: { locator } \to provider$

Initializes a new Rune provider. It requires a resource locator to determine the appropriate domains and names when resolving requested URLs.

```coffeescript
import RuneProvider from "@dashkite/sierra/rune"
import assert from "@dashkite/assert"

provider = RuneProvider.make { locator }
assert provider?
```

### encode
$encode: { rune, nonce } \to header$

Formats a resolved Rune and its associated nonce into a standard Authorization header string, utilizing the `rune` scheme.

```coffeescript
header = RuneProvider.encode { rune: "example-rune", nonce: "123" }
assert.equal (typeof header), "string"
```

### matches
$matches: query \to boolean$

Evaluates a specific query object to determine if the provider contains enough context to retrieve a Rune. It verifies the presence of an identity, url, and method.

```coffeescript
isMatch = provider.matches { identity: "alice", url: "https://example.com", method: "GET" }
assert.equal isMatch, true
```

### get
$get: { query } \dashrightarrow credential$

Executes the core Accessor Pattern logic. It breaks down the requested URL using the locator, traverses the necessary resources via the `@dashkite/runes-client` library, and aggregates the required cryptographic runes into a cohesive credential.

```coffeescript
credential = await provider.get { query: { identity: "alice", url: "https://example.com", method: "GET" } }
assert credential?
```

### store
$store: authorization \to \emptyset$

Delegates the persistence of an incoming Rune authorization directly to the underlying `runes-client` storage mechanism.

```coffeescript
provider.store { scheme: "rune", parameters: { rune: "example-rune" } }
assert true # verify successful completion
```
