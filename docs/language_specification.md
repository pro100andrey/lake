# Lake Language Specification

## 1. Overview

Lake is an Interface Definition Language (IDL) heavily inspired by Thrift. It is designed to define strictly-typed data structures, constants, and service interfaces in a clean, language-agnostic format.

## 2. File Structure

A `.lake` file consists of an optional block of **headers** followed by **definitions**.

```lake
// Headers
import "../tools/lake_lang/docs/common.lake"
namespace my.company.service

// Definitions
const i32 MAX_RETRIES = 5
```

## 3. Comments and Documentation

- **Single-line comment**: `// This is a comment`
- **Multi-line comment**: `/* This is a comment */`
- **Doc-comment**: `/// This is a doc comment` (Automatically parsed and attached to the definition or field immediately following it).

---

## 4. Types

### 4.1 Base Types

- `bool`: A boolean value (`true` or `false`).
- `byte` / `i8`: An 8-bit signed integer.
- `i16`: A 16-bit signed integer.
- `i32`: A 32-bit signed integer.
- `i64`: A 64-bit signed integer.
- `double`: A 64-bit floating point number.
- `string`: A text string.
- `binary`: A sequence of unencoded bytes.
- `uuid`: A Universally Unique Identifier.
- `void`: Represents no return value (only valid as a service method return type).

### 4.2 Container Types

- `list<T>`: An ordered list of elements of type `T`.
- `set<T>`: An unordered set of unique elements of type `T`.
- `map<K, V>`: A dictionary of key-value pairs mapping type `K` to type `V`.
- `stream<T>`: A continuous stream of elements of type `T` (typically used in service methods).

---

## 5. Literals

When assigning default values or constants, the following literals are supported:

- **Booleans**: `true`, `false`
- **Integers**: `123`, `-42`
- **Doubles**: `3.14`, `-0.5`, `1.5e10`
- **Strings**: `"Hello, World!"`
- **Lists**: `[1, 2, 3]`
- **Maps**: `{"key": "value", "key2": "value2"}`

---

## 6. Definitions

### 6.1 Constants (`const`)

Defines a global compile-time constant.

```lake
const i32 DEFAULT_TIMEOUT = 3000
const list<string> SUPPORTED_LANGS = ["en", "fr", "es"]
```

### 6.2 Typedefs (`typedef`)

Creates an alias for an existing type to improve readability.

```lake
typedef string UserId
typedef map<string, UserId> UserDirectory
```

### 6.3 Enums (`enum`)

Defines an enumeration of named integer values. Values can be assigned explicitly; if omitted, they are auto-incremented.

```lake
enum Status {
  UNKNOWN = 0,
  ACTIVE = 1,
  INACTIVE = 2
}
```

### 6.4 Structs (`struct`)

Defines a structured data object. Fields consist of an optional integer ID, an optional modifier (`required` or `optional`), a type, a name, and an optional default value.

```lake
struct UserProfile {
  1: required UserId id
  2: required string name
  3: optional i32 age = 18
  4: list<string> tags = []
}
```

### 6.5 Unions (`union`)

A union is syntactically identical to a struct, but semantically implies that only one of the defined fields can be populated at a given time.

```lake
union SearchResult {
  1: string success_message
  2: Exception error
}
```

### 6.6 Exceptions (`exception`)

Defines an error object that can be thrown by service methods. Syntax is identical to a `struct`.

```lake
exception NotFoundError {
  1: string message
  2: i32 error_code
}
```

### 6.7 Services (`service`)

Defines an RPC (Remote Procedure Call) interface. Services can extend a base service. Methods specify a return type, a name, parameters, and an optional `throws` clause for exceptions.

```lake
service UserService extends BaseService {
  /// Retrieves a user profile by ID
  UserProfile getUser(1: UserId id) throws (1: NotFoundError e)
  
  /// Pings the service
  void ping()
  
  /// Streams live user events
  stream<UserEvent> subscribeToEvents()
}
```
