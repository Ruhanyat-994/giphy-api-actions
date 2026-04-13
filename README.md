# Giphy PR Comment Action

A Docker-based GitHub Action that fetches a random GIF from the Giphy API and posts it as a comment on a Pull Request.

This action is triggered during PR events and automatically adds a “Thank you” message along with a GIF.

---

## How It Works

1. The action runs inside a Docker container.
2. It reads the Pull Request number from the GitHub event payload.
3. A request is sent to the Giphy API to fetch a random GIF.
4. The GIF URL is extracted using `jq`.
5. A comment is posted to the Pull Request using the GitHub REST API.

---

## Inputs

| Name            | Required | Description                     |
| --------------- | -------- | ------------------------------- |
| `github-token`  | Yes      | GitHub token for authentication |
| `giphy-api-key` | Yes      | Giphy API key                   |

---

## Usage

```yaml
name: PR Giphy Comment

on:
  pull_request:
    types: [opened]

jobs:
  giphy-comment:
    runs-on: ubuntu-latest

    permissions:
      pull-requests: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run Giphy PR Comment Action
        uses: your-username/your-repo-name@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          giphy-api-key: ${{ secrets.GIPHY_API_KEY }}
```

---

## Repository Structure

```
.
├── action.yml
├── Dockerfile
├── entrypoint.sh
└── README.md
```

---

## Entrypoint Script Overview

The `entrypoint.sh` script performs the following:

* Reads input arguments:

  * `$1` → GitHub token
  * `$2` → Giphy API key
* Extracts the Pull Request number from `$GITHUB_EVENT_PATH`
* Calls Giphy API:

  ```
  https://api.giphy.com/v1/gifs/random
  ```
* Parses the response using `jq`
* Posts a comment using:

  ```
  https://api.github.com/repos/{owner}/{repo}/issues/{pr_number}/comments
  ```

---

## Example Comment

```
### PR #12
### Thank you for this contribution!

![GIF](https://media.giphy.com/media/xxxx/giphy.gif)
```

---

## Required Secrets

Add the following secrets to your repository:

* `GITHUB_TOKEN` (automatically available in GitHub Actions)
* `GIPHY_API_KEY` (from Giphy Developers portal)


