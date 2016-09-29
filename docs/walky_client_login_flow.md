# Walky Client Login Flow

We only support login via external authentication system:

 * Watch Over Me
 * Facebook

---

## Watch Over Me

1. Login via Watch Over Me. Don't forget to include `X-Client-Id` with value `walky`.
2. Based on `auth_token` returned, make a request to Walky Server:

```
POST /api/v1/auth/wom
{
  "auth_token": "<VALID_AUTH_TOKEN_HERE>"
}
```

---

## Facebook

1. Login via Facebook
2. Send the `auth_token` to Walky Server:

```
POST /api/v1/auth/facebook
{
  "auth_token": "<VALID_AUTH_TOKEN_HERE>"
}
```

Response

```
{
  "status": "...",
  "access_token": "..."
}
```

The `status` might be `new_user` or `existing_user`.

---

## Get User Details

```
GET /api/v1/users/me
```

---

## Update User Details

```
PUT /api/v1/users/me
{
  "name": "<FULL_NAME>",
  "display_name": "<DISPLAY_NAME>"
}
```
