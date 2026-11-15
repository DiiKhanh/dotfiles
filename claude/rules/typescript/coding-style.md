---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript Coding Style

## Immutability

Use spread operator for immutable updates:

```typescript
// WRONG: Mutation
function updateUser(user, name) {
  user.name = name  // MUTATION!
  return user
}

// CORRECT: Immutability
function updateUser(user, name) {
  return {
    ...user,
    name
  }
}
```

## Error Handling

Use async/await with try-catch:

```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('Detailed user-friendly message')
}
```

## Input Validation

Use Zod for schema-based validation:

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

## Console.log

- No `console.log` statements in production code
- Use proper logging libraries instead

## Formatting and Type Checks

- Run the project's formatter (e.g. Prettier) on edited files
- Run `tsc` (or the project's type-check script) after editing `.ts`/`.tsx` files
