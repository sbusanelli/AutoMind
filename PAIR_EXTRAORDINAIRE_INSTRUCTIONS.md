# 👥 PairExtraordinaire Badge Instructions

## What Didn't Work
- ❌ Co-authored commit with fake email (AutoMind Bot)
- ❌ Direct commit to main (no PR involved)

## What Will Work
- ✅ Real GitHub collaborator
- ✅ Co-authored commit using their actual GitHub email
- ✅ Pull request that gets merged

## Step-by-Step Instructions

### 1. Find a Collaborator
Ask a friend/colleague who has a GitHub account to help you.

### 2. Create a Branch
```bash
git checkout -b pair-extraordinaire-attempt
```

### 3. Make a Small Change Together
Work together on any small change (typo fix, documentation update, etc.)

### 4. Commit with Real Co-author
```bash
git commit -m "fix: update documentation for PairExtraordinaire badge

Co-authored-by: FRIEND_NAME <FRIEND_EMAIL@example.com>"
```

### 5. Push and Create PR
```bash
git push origin pair-extraordinaire-attempt
gh pr create --title "PairExtraordinaire Badge Attempt" --body "This PR is co-authored to earn the PairExtraordinaire badge 👥"
```

### 6. Get it Merged
Ask your friend to merge the PR or merge it yourself if you have permissions.

## Alternative: Contribute to Open Source
Find an open source project and:
1. Find an issue to fix
2. Work with another contributor on the fix
3. Co-author the commit
4. Get PR merged

## Expected Result
Once the co-authored PR is merged, GitHub will automatically award you the 👥 PairExtraordinaire badge!
