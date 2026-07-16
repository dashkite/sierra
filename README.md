# @dashkite/sierra

*Helpers For Credentials*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

The Sierra library provides a foundational architecture for managing, storing, and retrieving credentials across different authentication schemes.

## Features

- Extensible registry for managing authentication providers.
- Built-in support for Rune-based credentials.
- Polymorphic authorization method using DashKite Generic.
- Support for compound credentials with JSON64 encoding.

## Installation

```bash
pnpm install @dashkite/sierra
```

## Usage

```coffeescript
import Registry from "@dashkite/sierra"
import RuneProvider from "@dashkite/sierra/rune"

registry = Registry.make()
registry.add "rune", RuneProvider.make { locator }
```

## Other Resources

- [Reference Documentation](docs/reference.md)
- [Usage Guides](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
