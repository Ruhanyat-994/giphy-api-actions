#!/bin/sh

set -e

GITHUB_TOKEN=$1
GIPHY_API_KEY=$2

echo "Starting Giphy PR Comment Action..."

# Extract PR number correctly
pull_request_number=$(jq --raw-output .number "$GITHUB_EVENT_PATH")

if [ -z "$pull_request_number" ] || [ "$pull_request_number" = "null" ]; then
  echo "Error: Could not extract pull request number"
  exit 1
fi

echo "PR Number: $pull_request_number"

# Call Giphy API
giphy_response=$(curl -s "https://api.giphy.com/v1/gifs/random?api_key=$GIPHY_API_KEY&tag=thank%20you&rating=g")

if [ -z "$giphy_response" ]; then
  echo "Error: Empty response from Giphy API"
  exit 1
fi

echo "Fetched Giphy response"

# Extract GIF URL safely
gif_url=$(echo "$giphy_response" | jq --raw-output '.data.images.downsized.url')

if [ -z "$gif_url" ] || [ "$gif_url" = "null" ]; then
  echo "Warning: No GIF found, using fallback"
  gif_url="https://media.giphy.com/media/3oEjI6SIIHBdRxXI40/giphy.gif"
fi

echo "GIF URL: $gif_url"

# Create comment payload safely
comment_body=$(jq -n --arg pr "$pull_request_number" --arg gif "$gif_url" \
  '{body: ("### PR #" + $pr + "\n### Thank you for this contribution!\n\n![GIF](" + $gif + ")")}'
)

# Post comment to GitHub
comment_response=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "$comment_body" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$pull_request_number/comments"
)

# Extract comment URL
comment_url=$(echo "$comment_response" | jq --raw-output '.html_url')

if [ "$comment_url" = "null" ] || [ -z "$comment_url" ]; then
  echo "Error: Failed to post comment"
  echo "$comment_response"
  exit 1
fi

echo "Comment posted successfully: $comment_url"