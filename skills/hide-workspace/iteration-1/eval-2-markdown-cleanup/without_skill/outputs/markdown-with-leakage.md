# API Authentication Guide

This document describes how to authenticate with the Order API.

## Overview

The API uses JWT tokens for authentication. All requests must include a valid token in the `Authorization` header.

Tokens expire after 24 hours and must be refreshed using the refresh token endpoint.

## Getting Started

```bash
# First, obtain a token
curl -X POST https://api.example.com/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username": "user@example.com", "password": "your-password"}'
```

The response includes both access and refresh tokens. The access token goes in the Authorization header.

## Token Refresh

Tokens should be refreshed before they expire. The refresh endpoint accepts the refresh token and returns a new access token.

```bash
curl -X POST https://api.example.com/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "your-refresh-token"}'
```

Error responses:
- 401: Invalid or expired token
- 403: Insufficient permissions
- 500: Server error

## Rate Limiting

Rate limits are enforced per-user:
- 100 requests per minute for standard users
- 1000 requests per minute for premium users

## Environment Configuration

Production: https://api.example.com
