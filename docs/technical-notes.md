# Technical Notes

### Accessor Pattern for Credentials

Sierra functions as an implementation of the Accessor Pattern for security credentials. By adhering to the Accessor Pattern, Sierra decouples how credentials are manipulated logically by libraries like Sublime from the physical process of accessing and retrieving them from the system. Sierra operates fundamentally as a structural bridge. Developers can register different types of accessor patterns as providers within the Sierra registry. Once registered, these strategies automatically become available to Sublime and other HTTP clients, effectively preventing duplicated access code across a project.

### Runes Integration

For handling rune-based credentials, Sierra relies on the foundational work provided by the `runes` and `runes-client` libraries. Sierra delegates the physical retrieval and validation to these underlying libraries while maintaining its role as the structural bridge for the Accessor Pattern.

### Generic Authorization Dispatch

The `authorization` method on the `Registry` class utilizes `@dashkite/generic` to implement polymorphic dispatch. This allows the method to accept either a single specifier object or an array of specifier objects. When provided an array, the method iterates through the sequence and returns the first successfully generated authorization header.

### Compound Credentials with JSON64

The `credentials` provider scheme encapsulates multiple distinct credentials within a single payload. It utilizes `JSON64` to stringify the credentials array and encode it safely, enabling transport of complex authorization structures through standard HTTP headers.
