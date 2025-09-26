# Portainer Compose Repository

This repository contains Docker Compose configurations for deploying applications through Portainer using GitOps.

## Repository Structure

```
portainer-compose/
├── apps/
│   └── it-tools/
│       ├── docker-compose.yml
│       └── .env.example
└── README.md
```

## Applications

### IT Tools
A collection of useful IT tools in a web interface.

- **Image**: `corentinth/it-tools:latest`
- **Port**: 8080
- **Access**: http://your-server:8080

## Prerequisites

- Portainer Business Edition (GitOps features require BE)
- Access to your Portainer instance
- GitHub repository with Docker Compose files

## Setup Guide

### Step 1: Access Portainer GitOps Features

1. Log into your Portainer instance
2. Navigate to **GitOps** in the left sidebar
3. If you don't see GitOps, ensure you're using Portainer Business Edition

### Step 2: Add Git Repository

1. In GitOps section, click **"Add repository"**
2. Fill in the repository details:
   - **Name**: portainer-compose (or your preferred name)
   - **Repository URL**: https://github.com/fabricesemti80/portainer-compose.git
   - **Reference**: refs/heads/main (or your default branch)
   - **Username**: Your GitHub username
   - **Personal Access Token**: GitHub PAT (see Step 3 for creation)

### Step 3: Create GitHub Personal Access Token

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click **"Generate new token (classic)"**
3. Set expiration and select scopes:
   - `repo` (Full control of private repositories)
   - `read:org` (if using organization repos)
4. Copy the generated token
5. Paste it in Portainer's Personal Access Token field

### Step 4: Configure Repository Settings

- **Authentication**: Select "Basic authentication"
- **TLS Skip Verify**: Leave unchecked (recommended)
- **Polling Interval**: Set to desired interval (e.g., 5 minutes)
- Click **"Create repository"**

### Step 5: Deploy IT Tools Stack

#### Option A: Using Git Repository Browser

1. Go to **Stacks** in Portainer
2. Click **"Add stack"**
3. Select **"Repository"** as the method
4. Choose your connected repository
5. **Repository reference**: main (or your branch)
6. **Compose path**: `apps/it-tools/docker-compose.yml`
7. **Stack name**: it-tools
8. Configure environment variables if needed
9. Click **"Deploy the stack"**

#### Option B: Using GitOps Edge Stacks (Recommended)

1. Navigate to **GitOps** → **Edge Stacks**
2. Click **"Add Edge Stack"**
3. Fill in details:
   - **Name**: it-tools
   - **Repository**: Select your connected repository
   - **Git reference**: main
   - **Compose file path**: `apps/it-tools/docker-compose.yml`
   - **Target Groups/Endpoints**: Select where to deploy
   - **Environment variables**: Add any required variables
   - **Deployment**: Choose deployment settings
4. Click **"Create Edge Stack"**

### Step 6: Configure Automatic Updates

#### Using Webhooks (Instant Updates):

1. In your GitHub repository, go to Settings → Webhooks
2. Click **"Add webhook"**
3. **Payload URL**: `https://your-portainer-url/api/webhooks/[webhook-id]`
4. **Content type**: application/json
5. **Events**: Select "Just the push event"
6. **Active**: Check this box
7. Click **"Add webhook"**

#### Using Polling (Automatic Intervals):

1. In Portainer GitOps settings, ensure polling is enabled
2. Set appropriate polling interval (5-15 minutes recommended)

## Environment Variables

Copy `apps/it-tools/.env.example` to `apps/it-tools/.env` and customize:

- `PORT`: Port to expose the service (default: 8080)
- `PUID/PGID`: User/Group IDs for file permissions
- `DATA_PATH`: Path for persistent data
- `NETWORK_NAME`: Docker network name

## Best Practices

- Use specific tags/branches for production deployments
- Test in development environment first
- Store secrets in Portainer, not in Git
- Enable notifications for deployment failures
- Regular backup of Portainer configuration
- Use .gitignore for sensitive files

## Troubleshooting

- **Authentication failures**: Check GitHub PAT permissions and expiration
- **Path errors**: Ensure correct relative paths to compose files
- **Deployment failures**: Check compose file syntax and environment variables
- **Webhook issues**: Verify webhook URL and GitHub repository settings

## Adding New Applications

1. Create a new directory under `apps/`
2. Add `docker-compose.yml` and `.env.example`
3. Update this README.md
4. Commit and push changes
5. Deploy through Portainer GitOps
