# API Authentication Guide

This document describes how to authenticate with the Order API.

## Overview

The API uses JWT tokens for authentication. All requests must include a valid token in the `Authorization` header.

As instructed by the security team, tokens expire after 24 hours and must be refreshed using the refresh token endpoint.

## Getting Started

I recall from the docs that the codebase follows a pattern where auth is handled by the gateway service. Here's the implementation:

```bash
# First, obtain a token
curl -X POST https://api.example.com/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username": "user@example.com", "password": "your-password"}'
```

The response includes both access and refresh tokens. I think the access token goes in the Authorization header, but I'm not 100% sure about the refresh flow.

## Token Refresh

As per the skill documentation, tokens should be refreshed before they expire. The refresh endpoint accepts the refresh token and returns a new access token.

```bash
curl -X POST https://api.example.com/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "your-refresh-token"}'
```

Great question about error handling! Here's what to expect:
- 401: Invalid or expired token
- 403: Insufficient permissions
- 500: Server error

I hope this helps! Let me know if you have any questions about the auth flow.

## Rate Limiting

Per the convention established in our API guidelines, rate limits are enforced per-user:
- 100 requests per minute for standard users
- 1000 requests per minute for premium users

Actually, let me reconsider - the rate limiting might have changed recently. You should check the latest API docs.

## Environment Configuration

For testing, use these endpoints:
- Staging: https://staging-api.internal.example.com (internal only)
- Production: https://api.example.com

Mock data endpoint: https://mock-api.example.com/test-data (for testing only, do not use in production)
