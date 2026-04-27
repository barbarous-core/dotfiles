#!/bin/bash

SESSION_NAME=$1

# 1. Validation: Ensure a name is provided
if [ -z "$SESSION_NAME" ]; then
    echo "Usage: $0 [session_name]"
    exit 1
fi

# 2. Creation: Create the session if it doesn't exist
# We use 'has-session' to check quietly
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
    echo "Created new session: $SESSION_NAME"
fi

# 3. Connection: Attach or Switch
if [ -z "$TMUX" ]; then
    # We are OUTSIDE tmux, so attach normally
    tmux attach-session -t "$SESSION_NAME"
else
    # We are INSIDE tmux, so switch the current client to the new session
    tmux switch-client -t "$SESSION_NAME"
fi
