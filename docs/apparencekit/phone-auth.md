# ApparenceKit Phone Authentication

> Source: https://apparencekit.dev/docs/start/overview/

## Overview

Phone authentication uses Firebase Auth's phone sign-in provider, which sends an SMS verification code to the user's phone number.

## Setup

1. Enable Phone provider in Firebase Console > Authentication > Sign-in method
2. Add test phone numbers in Firebase Console for development
3. For production: Configure SMS quota and billing

## Flow

1. User enters phone number
2. App calls `FirebaseAuth.verifyPhoneNumber()`
3. Firebase sends SMS with verification code
4. User enters the code
5. App verifies the code with `PhoneAuthCredential`
6. On success, user is signed in

## Code Structure

- **Phone Auth Notifier** (`lib/modules/authentication/providers/phone_auth_notifier.dart`) — Manages phone auth state
- **Phone Auth State** (`lib/modules/authentication/providers/models/phone_signin_state.dart`) — Freezed state model
- **Phone Auth UI** — Phone number input page + OTP verification page

## State Flow

```
PhoneSigninInitial
  → PhoneSigninCodeSent (after SMS sent)
  → PhoneSigninSuccess (after OTP verified)
  → PhoneSigninError (on any error)
```

## Important Notes

- Phone auth has a **2000ms artificial delay** to prevent spamming (see KNOWN_ISSUES.md)
- The `verifyOtp` catch block correctly passes `state.phoneNumber` (fixed from Firebase sister repo)
- Test phone numbers should be configured in Firebase Console for development to avoid SMS charges
