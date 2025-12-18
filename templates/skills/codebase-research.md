# Codebase Research Skill

**Auto-invoke when:** User asks about existing code patterns, architecture, or how something works in the codebase.

**Trigger patterns:**
- "How does [feature] work?"
- "Where is [component] implemented?"
- "What pattern does the codebase use for [concept]?"
- "Find all [entity] definitions"
- "Show me examples of [pattern]"

## Purpose

Efficiently research and summarize codebase patterns, architectures, and implementations using specialized agents to reduce token usage in main conversation.

## Research Strategy

**Always use Task tool with Explore agent:**
- Model: `sonnet` (needs code understanding)
- Agent type: `Explore`
- Returns: Focused summaries, not full file contents

## Research Patterns

### Pattern 1: Feature Location
**User asks:** "Where is user authentication implemented?"

**Agent prompt:**
```
"Find all files related to user authentication. Return:
- Auth service files (with paths)
- Auth middleware (with paths)
- Auth routes/endpoints (with paths)
- Key functions (name + file:line)
Max 300 words."
```

### Pattern 2: Architecture Analysis
**User asks:** "How does the codebase handle database connections?"

**Agent prompt:**
```
"Analyze database connection handling. Return:
- Connection setup pattern (connection pooling, singleton, etc.)
- File where connections are configured
- How connections are shared across modules
- Example usage (2-3 line snippet)
Max 250 words."
```

### Pattern 3: Pattern Examples
**User asks:** "Show me how error handling works"

**Agent prompt:**
```
"Find error handling patterns. Return:
- Error handling approach (try/catch, error middleware, etc.)
- 2-3 example files with line numbers
- Common error types used
- Standard error response format
Max 300 words."
```

### Pattern 4: Entity Discovery
**User asks:** "Find all User model definitions"

**Agent prompt:**
```
"Find User model/entity definitions. Return:
- File paths for User models
- Key properties/fields
- Relationships to other entities
- Validation rules (if present)
Max 200 words."
```

## Execution Flow

1. **Identify research type** (location, architecture, pattern, entity)
2. **Dispatch Explore agent** with focused prompt
3. **Receive summary** (not full files)
4. **Answer user** with structured findings
5. **Offer follow-up**: "Want to see specific implementations?"

## Output Format

```markdown
# Research Results: User Authentication

## Location
- **Service**: `src/services/auth-service.js:15-89`
- **Middleware**: `src/middleware/authenticate.js:8-45`
- **Routes**: `src/routes/auth-routes.js:12-67`

## Architecture
- Pattern: JWT-based authentication
- Token storage: HTTP-only cookies
- Session management: Redis (connect-redis)

## Key Functions
- `authenticateUser()` - `auth-service.js:22`
- `verifyToken()` - `auth-service.js:45`
- `refreshToken()` - `auth-service.js:67`

## Example Usage
```javascript
// src/routes/protected-routes.js:15
router.get('/profile', authenticate, getProfile)
```

**Next steps**: Want to see the full `authenticateUser()` implementation?
```

## Token Optimization

**Without skill** (main conversation loads files):
```
Read auth-service.js → 2,500 tokens
Read authenticate.js → 1,800 tokens
Read auth-routes.js → 1,200 tokens
Total: 5,500 tokens
```

**With skill** (agent returns summary):
```
Agent research (Explore) → 800 tokens
Agent summary → 250 tokens
Main conversation → 150 tokens
Total: 1,200 tokens (78% reduction)
```

## Model Usage
- **Sonnet** for code understanding (Explore agent)
- Falls back to Haiku if simple file listing
- Parallel agents for multi-aspect research
