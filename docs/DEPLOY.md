# Deployment Workflow

## GitHub Pages (Static Site)

Deploys from `main` branch. No build step — push to main and it's live.

### Push Workflow
```bash
git add -A && git commit -m "message" && git push
```

### Post-Push Verification
1. Wait ~60s for CI to run
2. `git pull --rebase origin main`
3. Read `version.json` — report version

### Version Format
`vYYMMDD.NN H:MMa` — date + daily counter + local time.
CI bumps automatically via GitHub Action on every push. **Never bump locally.**

## Live URLs

| Environment | URL |
|---|---|
| Live site (custom domain) | https://theanimistapothecary.com |
| Admin Command Center | https://theanimistapothecary.com/admin/ |
| Client Portal | https://theanimistapothecary.com/portal/ |
| CRM | https://theanimistapothecary.com/crm/ |
| GitHub Pages (backup) | https://adimarie.github.io/AdiMarie/ |
| GitHub Repo | https://github.com/adimarie/AdiMarie |
