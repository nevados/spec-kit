#!/usr/bin/env bash

set -e

JSON_MODE=false
SHORT_NAME=""
BRANCH_NUMBER=""
ISSUE_NUMBER=""
ISSUE_URL=""
ARGS=()
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json) 
            JSON_MODE=true 
            ;;
        --short-name)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --short-name requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            # Check if the next argument is another option (starts with --)
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --short-name requires a value' >&2
                exit 1
            fi
            SHORT_NAME="$next_arg"
            ;;
        --number)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --number requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --number requires a value' >&2
                exit 1
            fi
            BRANCH_NUMBER="$next_arg"
            ;;
        --issue)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --issue requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --issue requires a value' >&2
                exit 1
            fi
            # Parse issue number from number or URL
            if [[ "$next_arg" =~ ^[0-9]+$ ]]; then
                # Just a number
                ISSUE_NUMBER="$next_arg"
            elif [[ "$next_arg" =~ github\.com/[^/]+/[^/]+/issues/([0-9]+) ]]; then
                # GitHub URL
                ISSUE_NUMBER="${BASH_REMATCH[1]}"
            else
                echo "Error: --issue must be a number or GitHub issue URL" >&2
                exit 1
            fi
            ;;

        --help|-h)
            echo "Usage: $0 [--json] [--short-name <name>] [--issue <number|URL>] <feature_description>"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --short-name <name> Provide a custom short name (2-4 words) for the branch"
            echo "  --issue <N|URL>     Use existing GitHub issue (number or URL)"
            echo "  --number N          (Deprecated) Use --issue instead"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 'Add user authentication system'"
            echo "  $0 --issue 2011 'Upgrade dependencies'"
            echo "  $0 --issue https://github.com/owner/repo/issues/2011 'Upgrade dependencies'"
            exit 0
            ;;
        *) 
            ARGS+=("$arg") 
            ;;
    esac
    i=$((i + 1))
done

FEATURE_DESCRIPTION="${ARGS[*]}"
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] [--short-name <name>] [--number N] <feature_description>" >&2
    exit 1
fi

# Function to find the repository root by searching for existing project markers
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Function to create or fetch GitHub issue
get_or_create_issue() {
    local description="$1"

    if [ -n "$ISSUE_NUMBER" ]; then
        # Fetch existing issue
        local issue_json=$(gh issue view "$ISSUE_NUMBER" --json number,title,state 2>&1)
        if [ $? -ne 0 ]; then
            echo "Error: Failed to fetch issue #$ISSUE_NUMBER" >&2
            echo "$issue_json" >&2
            exit 1
        fi

        local issue_state=$(echo "$issue_json" | jq -r '.state')
        if [ "$issue_state" = "CLOSED" ]; then
            echo "Warning: Issue #$ISSUE_NUMBER is closed" >&2
        fi

        echo "$issue_json"
    else
        # Create new issue - extract title from description (first sentence or 2-8 words)
        local title=$(echo "$description" | head -n 1 | cut -c 1-100)

        # Create issue with spec label and assign to current user
        local issue_json=$(gh issue create \
            --title "$title" \
            --body "$description" \
            --label "spec" 2>&1)

        if [ $? -ne 0 ]; then
            echo "Error: Failed to create GitHub issue" >&2
            echo "$issue_json" >&2
            exit 1
        fi

        # Extract issue number from URL (gh issue create returns URL)
        if [[ "$issue_json" =~ /issues/([0-9]+) ]]; then
            local new_issue_num="${BASH_REMATCH[1]}"
            ISSUE_NUMBER="$new_issue_num"

            # Set issue type to Enhancement
            set_issue_type_enhancement "$new_issue_num"

            # Fetch the created issue details
            gh issue view "$new_issue_num" --json number,title,state
        else
            echo "Error: Could not extract issue number from: $issue_json" >&2
            exit 1
        fi
    fi
}

# Function to set issue type to Enhancement via GraphQL
set_issue_type_enhancement() {
    local issue_num="$1"

    # Get current repo owner and name
    local repo_info=$(gh repo view --json owner,name 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Warning: Could not get repo info, skipping issue type" >&2
        return
    fi

    local owner=$(echo "$repo_info" | jq -r '.owner.login')
    local repo_name=$(echo "$repo_info" | jq -r '.name')

    # Get issue node ID
    local issue_id=$(gh issue view "$issue_num" --json id --jq '.id' 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$issue_id" ]; then
        echo "Warning: Could not get issue ID, skipping issue type" >&2
        return
    fi

    # Get Enhancement type ID from repo
    local type_id=$(gh api graphql -H "GraphQL-Features: issue_types" -f query='
        query($owner: String!, $repo: String!) {
            repository(owner: $owner, name: $repo) {
                issueTypes { id name }
            }
        }' -F owner="$owner" -F repo="$repo_name" 2>/dev/null | \
        jq -r '.data.repository.issueTypes[]? | select(.name=="Enhancement") | .id')

    if [ -z "$type_id" ]; then
        echo "Warning: Enhancement issue type not found in repo, skipping" >&2
        return
    fi

    # Update issue with type
    gh api graphql -H "GraphQL-Features: issue_types" -f query='
        mutation {
            updateIssue(input: {
                id: "'"$issue_id"'"
                issueTypeId: "'"$type_id"'"
            }) {
                issue { id title }
            }
        }' >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "Warning: Failed to set issue type, continuing anyway" >&2
    fi
}


# Function to clean and format a branch name
clean_branch_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Resolve repository root. Prefer git information when available, but fall back
# to searching for repository markers so the workflow still functions in repositories that
# were initialised with --no-git.
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    HAS_GIT=true
else
    REPO_ROOT="$(find_repo_root "$SCRIPT_DIR")"
    if [ -z "$REPO_ROOT" ]; then
        echo "Error: Could not determine repository root. Please run this script from within the repository." >&2
        exit 1
    fi
    HAS_GIT=false
fi

cd "$REPO_ROOT"

SPECS_DIR="$REPO_ROOT/specs"
mkdir -p "$SPECS_DIR"

# Function to generate branch name with stop word filtering and length filtering
generate_branch_name() {
    local description="$1"
    
    # Common stop words to filter out
    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set)$"
    
    # Convert to lowercase and split into words
    local clean_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')
    
    # Filter words: remove stop words and words shorter than 3 chars (unless they're uppercase acronyms in original)
    local meaningful_words=()
    for word in $clean_name; do
        # Skip empty words
        [ -z "$word" ] && continue
        
        # Keep words that are NOT stop words AND (length >= 3 OR are potential acronyms)
        if ! echo "$word" | grep -qiE "$stop_words"; then
            if [ ${#word} -ge 3 ]; then
                meaningful_words+=("$word")
            elif echo "$description" | grep -q "\b${word^^}\b"; then
                # Keep short words if they appear as uppercase in original (likely acronyms)
                meaningful_words+=("$word")
            fi
        fi
    done
    
    # If we have meaningful words, use first 3-4 of them
    if [ ${#meaningful_words[@]} -gt 0 ]; then
        local max_words=3
        if [ ${#meaningful_words[@]} -eq 4 ]; then max_words=4; fi
        
        local result=""
        local count=0
        for word in "${meaningful_words[@]}"; do
            if [ $count -ge $max_words ]; then break; fi
            if [ -n "$result" ]; then result="$result-"; fi
            result="$result$word"
            count=$((count + 1))
        done
        echo "$result"
    else
        # Fallback to original logic if no meaningful words found
        local cleaned=$(clean_branch_name "$description")
        echo "$cleaned" | tr '-' '\n' | grep -v '^$' | head -3 | tr '\n' '-' | sed 's/-$//'
    fi
}

# Handle GitHub issue - create or fetch
ISSUE_JSON=$(get_or_create_issue "$FEATURE_DESCRIPTION")
ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
ISSUE_URL="https://github.com/$(gh repo view --json nameWithOwner --jq '.nameWithOwner')/issues/$ISSUE_NUMBER"

>&2 echo "[specify] Using issue #$ISSUE_NUMBER: $ISSUE_TITLE"

# Generate branch name from issue title
if [ -n "$SHORT_NAME" ]; then
    # Use provided short name, just clean it up
    BRANCH_SUFFIX=$(clean_branch_name "$SHORT_NAME")
else
    # Generate from issue title with smart filtering
    BRANCH_SUFFIX=$(generate_branch_name "$ISSUE_TITLE")
fi

# Use issue number as branch prefix (no zero-padding)
FEATURE_NUM="$ISSUE_NUMBER"
BRANCH_NAME="${FEATURE_NUM}-${BRANCH_SUFFIX}"

# GitHub enforces a 244-byte limit on branch names
# Validate and truncate if necessary
MAX_BRANCH_LENGTH=244
if [ ${#BRANCH_NAME} -gt $MAX_BRANCH_LENGTH ]; then
    # Calculate how much we need to trim from suffix
    # Account for: issue number length + hyphen (1)
    ISSUE_NUM_LENGTH=${#FEATURE_NUM}
    MAX_SUFFIX_LENGTH=$((MAX_BRANCH_LENGTH - ISSUE_NUM_LENGTH - 1))

    # Truncate suffix at word boundary if possible
    TRUNCATED_SUFFIX=$(echo "$BRANCH_SUFFIX" | cut -c1-$MAX_SUFFIX_LENGTH)
    # Remove trailing hyphen if truncation created one
    TRUNCATED_SUFFIX=$(echo "$TRUNCATED_SUFFIX" | sed 's/-$//')

    ORIGINAL_BRANCH_NAME="$BRANCH_NAME"
    BRANCH_NAME="${FEATURE_NUM}-${TRUNCATED_SUFFIX}"

    >&2 echo "[specify] Warning: Branch name exceeded GitHub's 244-byte limit"
    >&2 echo "[specify] Original: $ORIGINAL_BRANCH_NAME (${#ORIGINAL_BRANCH_NAME} bytes)"
    >&2 echo "[specify] Truncated to: $BRANCH_NAME (${#BRANCH_NAME} bytes)"
fi

# Check if branch already exists and handle accordingly
BRANCH_EXISTED=false
PR_URL=""

if [ "$HAS_GIT" = true ]; then
    # Check if branch exists locally or remotely
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
        >&2 echo "[specify] Branch $BRANCH_NAME already exists locally, checking out..."
        git checkout "$BRANCH_NAME"
        BRANCH_EXISTED=true
    elif git ls-remote --heads origin "$BRANCH_NAME" 2>/dev/null | grep -q "$BRANCH_NAME"; then
        >&2 echo "[specify] Branch $BRANCH_NAME exists on remote, checking out..."
        git fetch origin "$BRANCH_NAME"
        git checkout "$BRANCH_NAME"
        BRANCH_EXISTED=true
    else
        # Create new branch
        git checkout -b "$BRANCH_NAME"
        BRANCH_EXISTED=false
    fi
else
    >&2 echo "[specify] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME"
fi

FEATURE_DIR="$SPECS_DIR/$BRANCH_NAME"
mkdir -p "$FEATURE_DIR"

TEMPLATE="$REPO_ROOT/.specify/templates/spec-template.md"
SPEC_FILE="$FEATURE_DIR/spec.md"
if [ -f "$TEMPLATE" ]; then cp "$TEMPLATE" "$SPEC_FILE"; else touch "$SPEC_FILE"; fi

# Set the SPECIFY_FEATURE environment variable for the current session
export SPECIFY_FEATURE="$BRANCH_NAME"

# Push branch and create draft PR if this is a new branch
if [ "$BRANCH_EXISTED" = false ] && [ "$HAS_GIT" = true ]; then
    >&2 echo "[specify] Pushing branch to origin..."
    if git push -u origin "$BRANCH_NAME" 2>&1; then
        >&2 echo "[specify] Creating draft PR..."
        PR_URL=$(gh pr create --draft \
            --title "spec: $ISSUE_TITLE" \
            --body "Closes #$ISSUE_NUMBER

Specification for: $ISSUE_TITLE

This PR contains the specification document for the feature described in issue #$ISSUE_NUMBER." \
            --base main 2>&1) || {
            >&2 echo "[specify] Warning: Failed to create PR"
            PR_URL=""
        }

        if [ -n "$PR_URL" ]; then
            >&2 echo "[specify] Draft PR created: $PR_URL"
        fi
    else
        >&2 echo "[specify] Warning: Failed to push branch (no remote or permission denied)"
    fi
fi

if $JSON_MODE; then
    printf '{"BRANCH_NAME":"%s","SPEC_FILE":"%s","FEATURE_NUM":"%s","ISSUE_NUMBER":"%s","ISSUE_URL":"%s","PR_URL":"%s"}\n' \
        "$BRANCH_NAME" "$SPEC_FILE" "$FEATURE_NUM" "$ISSUE_NUMBER" "$ISSUE_URL" "$PR_URL"
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "SPEC_FILE: $SPEC_FILE"
    echo "FEATURE_NUM: $FEATURE_NUM"
    echo "ISSUE_NUMBER: $ISSUE_NUMBER"
    echo "ISSUE_URL: $ISSUE_URL"
    if [ -n "$PR_URL" ]; then
        echo "PR_URL: $PR_URL"
    fi
    echo "SPECIFY_FEATURE environment variable set to: $BRANCH_NAME"
fi
