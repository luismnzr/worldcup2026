# Eclipse — Internal Operations Docs

This folder contains **operations documentation** used when setting up and deploying Eclipse for a new client. It is intentionally minimal — the full user-facing and developer documentation lives in a separate repository and is published as a public site.

## Documentation locations

| Audience | Where | Purpose |
|----------|-------|---------|
| **Studio owners & staff** (Spanish) | [docs.eclipsecms.com](https://docs.eclipsecms.com) | End-user manual for using Eclipse |
| **Developers** (English) | [docs.eclipsecms.com/guide/introduction](https://docs.eclipsecms.com/guide/introduction) | Technical reference for the codebase |
| **Operations / deployment** (this folder) | `docs/` in this repo | Client setup and deployment checklists |

The user manual and developer docs are maintained in the [`eclipse-docs`](https://github.com/luismnzr/eclipse-docs) repository and deployed to Vercel.

## Files in this folder

| Document | Description |
|----------|-------------|
| [Client Setup Guide](./CLIENT_SETUP_GUIDE.md) | Step-by-step walkthrough for cloning and configuring Eclipse for a new client |
| [Deployment Guide](./DEPLOYMENT_GUIDE.md) | Production deployment checklist for Heroku |

## Why the split?

Eclipse is a white-label platform — the `eclipse-v1` repository is cloned once per client. Keeping the base repo focused on the application (and the minimal operations docs needed to deploy it) means:

- Client clones stay clean and focused
- No doc bloat in each deployment
- Public documentation lives in one place (`docs.eclipsecms.com`) instead of being duplicated across every client clone
- Documentation updates don't create noisy `git pull` diffs for client clones
