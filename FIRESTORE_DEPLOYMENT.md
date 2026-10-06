# Firestore Security Rules - Deployment Guide

This guide explains how to deploy and manage Firestore security rules for puzzle_match.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Understanding the Rules](#understanding-the-rules)
- [Deployment Methods](#deployment-methods)
- [Testing Rules](#testing-rules)
- [Monitoring & Troubleshooting](#monitoring--troubleshooting)
- [Best Practices](#best-practices)

---

## Prerequisites

### Required Tools

1. **Firebase CLI**: [Install Firebase Tools](https://firebase.google.com/docs/cli)
   ```bash
   npm install -g firebase-tools
   ```

2. **Authentication**: Login to Firebase
   ```bash
   firebase login
   ```

3. **Project Setup**: Initialize Firebase in the project
   ```bash
   firebase init
   ```

### Project Structure

The `firestore.rules` file contains security rules for three collections:

```
firestore.rules          # Security rules file (in repo root)
├── /users/{userId}      # User profiles
├── /solutions/{doc}     # Puzzle solutions
└── /close_call_stats/{userId}/{doc}  # User statistics
```

---

## Understanding the Rules

### Rule 1: User Documents

```firestore
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

**Effect:**
- Only authenticated users can access their own user document
- Users CANNOT see other users' documents
- Users can create, read, and update their own profile

**Example:**
- ✅ User A can read/write `/users/userA`
- ❌ User A cannot read `/users/userB`

### Rule 2: Solutions Collection

```firestore
match /solutions/{document=**} {
  allow read, write: if request.auth != null;
}
```

**Effect:**
- Any authenticated user can read solutions
- Any authenticated user can write/submit solutions
- Anonymous users cannot access

**Example:**
- ✅ Authenticated user can submit solution to `/solutions/puzzle123`
- ✅ Authenticated user can view `/solutions/puzzle456`
- ❌ Anonymous user cannot access

### Rule 3: Close Call Stats

```firestore
match /close_call_stats/{userId}/{document=**} {
  allow read, write: if request.auth.uid == userId;
}
```

**Effect:**
- Only the owner can access their close call statistics
- Similar to user documents but organized under userId
- Private user statistics

**Example:**
- ✅ User A can read/write `/close_call_stats/userA/stats`
- ❌ User A cannot access `/close_call_stats/userB/stats`

---

## Deployment Methods

### Method 1: Firebase Console (Easiest)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (puzzle-match-app)
3. Navigate to **Firestore Database** → **Rules**
4. Replace the rules with content from `firestore.rules`
5. Click **Publish**

### Method 2: Firebase CLI (Recommended)

```bash
# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Deploy all (functions, hosting, rules)
firebase deploy
```

**Output:**
```
✔ firestore:rules deployed successfully

Function discovery complete in 2s
❯ firestore:rules 75 B 0B

Deploy complete!
```

### Method 3: CI/CD Pipeline

Add to `.github/workflows/deploy.yml`:

```yaml
- name: Deploy Firestore Rules
  run: firebase deploy --only firestore:rules
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

To set up CI/CD:

1. Generate Firebase token: `firebase login:ci`
2. Add to GitHub Secrets: `Settings → Secrets → FIREBASE_TOKEN`

---

## Testing Rules

### Local Testing with Emulator

```bash
# Start Firestore emulator
firebase emulators:start --only firestore

# In another terminal, run tests against emulator
FIRESTORE_EMULATOR_HOST=localhost:8080 flutter test
```

### Test Cases

```dart
// Test 1: User can read own document
test('user can read own document', () async {
  final user = firebase.auth.currentUser;
  final doc = await db.collection('users').doc(user.uid).get();
  expect(doc.exists, true);
});

// Test 2: User cannot read other user's document
test('user cannot read other user document', () async {
  expect(
    () => db.collection('users').doc('otherUserId').get(),
    throwsFirebaseException,
  );
});

// Test 3: Authenticated user can submit solution
test('authenticated user can submit solution', () async {
  await db.collection('solutions').add({
    'puzzleId': 'puzzle123',
    'userId': currentUser.uid,
    'answer': 'solution',
  });
});
```

### Manual Testing in Console

1. Go to **Firestore Database → Rules**
2. Click **Simulator** (if available)
3. Test read/write operations with different auth scenarios

---

## Monitoring & Troubleshooting

### Permission Denied Errors

**Error:** `Error: PERMISSION_DENIED: Missing or insufficient permissions`

**Causes:**
- User not authenticated
- User doesn't own the document
- Rule syntax error

**Solution:**
1. Verify user is authenticated
2. Check user UID matches document path
3. Review rules for typos

### Rules Not Taking Effect

**Problem:** Old rules still apply after deployment

**Solutions:**
1. Clear browser cache
2. Restart app completely
3. Verify deployment succeeded: `firebase deploy --only firestore:rules --debug`
4. Check Firebase Console for deployment status

### Testing in Production

**Safe approach:**
1. Deploy to staging project first
2. Test thoroughly with real data
3. Deploy to production during low-traffic period
4. Monitor error rates for 30 minutes

---

## Best Practices

### Security

✅ **DO:**
- Restrict access by user ID
- Verify authentication before allowing writes
- Use specific paths (avoid wildcards in critical rules)
- Test rules in emulator first

❌ **DON'T:**
- Use overly permissive `allow read, write: if true;`
- Trust client-side validation alone
- Deploy rules without testing
- Leave test/debug rules in production

### Organization

**Collection Naming:**
- Use lowercase with underscores: `/close_call_stats`
- Use singular for document types: `/users/{userId}`
- Avoid deeply nested structures (3 levels max)

**Rule Organization:**
```firestore
// Group related rules
match /users/{userId} {
  // User-specific rules
  match /profile {
    allow read, write: if request.auth.uid == userId;
  }
  
  match /settings {
    allow read, write: if request.auth.uid == userId;
  }
}
```

### Performance

**Optimize Rules:**
- Use field-level validation for large documents
- Index frequently filtered fields
- Avoid expensive operations in rules
- Monitor query performance in Firestore console

**Index Strategy:**
- Let Firestore auto-create indexes
- Manually create only if needed
- Monitor index usage in console

---

## Maintenance

### Regular Tasks

- **Monthly:** Review rule logs in Firestore console
- **Quarterly:** Audit collection structure for growth
- **Annually:** Security review of all rules

### Version Control

Keep `firestore.rules` in git:

```bash
# Track changes
git add firestore.rules
git commit -m "security: update firestore rules for X feature"
git push
```

### Backup

Export rules regularly:

```bash
# Export to file
firebase firestore:indexes describe > firestore-indexes.json

# Export security rules
firebase firestore:describe-firestore > firestore-config.json
```

---

## Troubleshooting Reference

| Error | Cause | Solution |
|-------|-------|----------|
| `PERMISSION_DENIED` | User not authenticated | Verify user auth state |
| `NOT_FOUND` | Document doesn't exist | Check document path |
| `INVALID_ARGUMENT` | Bad request format | Validate data structure |
| `UNAUTHENTICATED` | No auth token | Re-authenticate user |
| `FAILED_PRECONDITION` | Rule violation | Check rule conditions |

---

## Additional Resources

- [Firebase Firestore Rules Documentation](https://firebase.google.com/docs/firestore/security/start)
- [Rules Playground](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [Security Rules Learning Path](https://firebase.google.com/learn/pathways/security-rules)
- [Common Security Patterns](https://firebase.google.com/docs/firestore/security/rules-conditions)

---

**Last Updated:** 2026-10-06  
**Status:** Production Ready  
**Maintained by:** puzzle_match team
