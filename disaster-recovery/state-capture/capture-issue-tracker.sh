#!/usr/bin/env bash
# capture-issue-tracker.sh -- Capture issue tracker state via API (read-only)
#
# All operations are read-only API GET requests.
# This script is written for Gitea. Adapt for GitHub, GitLab, or other platforms.
#
# CUSTOMIZATION:
# - Update TRACKER_URL with your issue tracker's base URL
# - Update TRACKER_TOKEN with your API token (or use env var)
# - Update org name and repo names in the loops below
# - For GitHub: change API paths (/api/v1 -> /api/v3 or just use gh CLI)
# - For GitLab: change API paths (/api/v1 -> /api/v4)
#
set -euo pipefail

# CUSTOMIZATION: Set these for your environment
TRACKER_URL="https://git.lab.example.com:8084"
TRACKER_TOKEN="${TRACKER_API_TOKEN:-your-api-token-here}"

SNAP_DIR="${1:-$(dirname "$0")/snapshots/$(date +%Y-%m-%d)/issue-tracker}"
mkdir -p "$SNAP_DIR"
echo "Capturing issue tracker state to $SNAP_DIR ..."

# Helper: make an API GET request, save result to file
api() {
    local endpoint="$1"
    local outfile="$2"
    curl -sk -H "Authorization: token $TRACKER_TOKEN" \
         "${TRACKER_URL}/api/v1${endpoint}" > "$SNAP_DIR/$outfile" 2>/dev/null || \
    echo "{\"error\": \"API call failed: $endpoint\"}" > "$SNAP_DIR/$outfile"
}

# Server info
api "/version" "version.json"

# Users and orgs (admin endpoints -- may require admin token)
api "/admin/users?limit=50" "users.json"
api "/admin/orgs?limit=50" "orgs.json"

# User repos
api "/user/repos?limit=50" "user-repos.json"

# CUSTOMIZATION: Update org name and repo list for your environment
ORG="my-org"

# Org repos
api "/orgs/${ORG}/repos?limit=100" "repos.json"
api "/orgs/${ORG}/labels?limit=100" "labels-org.json"

# Issues for key repos (paginated, max 2 pages each)
# CUSTOMIZATION: List your most important repos here
for repo in infrastructure operations; do
    for page in 1 2; do
        api "/repos/${ORG}/${repo}/issues?state=open&type=issues&limit=50&page=${page}" \
            "issues-${repo}-p${page}.json"
    done
    # Closed issues (page 1 only)
    api "/repos/${ORG}/${repo}/issues?state=closed&type=issues&limit=50&page=1" \
        "issues-${repo}-closed-p1.json"
done

# Milestones for key repos
for repo in infrastructure operations; do
    api "/repos/${ORG}/${repo}/milestones?state=all&limit=50" \
        "milestones-${repo}.json"
done

echo "Issue tracker capture complete: $(ls "$SNAP_DIR" | wc -l) files"
