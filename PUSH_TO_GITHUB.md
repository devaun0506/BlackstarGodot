# Push Blackstar to GitHub

Your Blackstar medical education game is ready to push to GitHub! Since the GitHub CLI is not installed, follow these steps:

## Option 1: Using GitHub Website

1. Go to https://github.com/new
2. Create a new repository named "blackstar" or "blackstar-medical-game"
3. Make it public or private as you prefer
4. Don't initialize with README (we already have one)
5. After creating, GitHub will show you commands. Run these in your terminal:

```bash
git remote add origin https://github.com/YOUR_USERNAME/blackstar.git
git branch -M main
git push -u origin main
```

## Option 2: Install GitHub CLI First

```bash
# Install GitHub CLI on macOS
brew install gh

# Authenticate
gh auth login

# Create repo and push
gh repo create blackstar --public --source=. --remote=origin --push
```

## Option 3: Using Existing Repository

If you already have a repository:

```bash
git remote add origin YOUR_REPO_URL
git push -u origin main
```

## Current Git Status

- ✅ Repository initialized
- ✅ All files committed
- ✅ Clean working directory
- ✅ Ready to push

## Repository Description

**Blackstar**: A high-pressure medical decision-making game for Step 2 CK preparation

Transform emergency medicine training into an engaging game where you play as an Emergency Department Attending during chaotic night shifts. Make rapid, critical decisions as patient charts slide across your desk in this medically accurate educational experience.

**Features:**
- 20+ NBME-style Step 2 CK questions
- Pixel art hospital environment
- Adaptive learning algorithm
- 15-17 shift story campaign
- Medical accuracy with 2024-2025 guidelines

Built with Godot 4 | Medical Education Gaming