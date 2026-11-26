# 📚 Bookstore App

A bookstore application designed to help users discover books, explore categories and vendors, manage their wishlist, and maintain their personal profile.

## Features

### Authentication
- Splash screen with session checking
- Sign in with email and password
- Sign up with name, email, password, and password confirmation
- Forgot password functionality
- Persistent authentication using Supabase
- Automatic navigation based on authentication state

### Home
- Featured books displayed horizontally
- Browse featured books with a "See All" option
- Featured vendors section
- Search functionality

### Book Discovery
- Browse all books in a grid layout
- View detailed book information
- Explore book categories

### Wishlist
- Add books to wishlist using the like button
- View saved books
- Remove books from wishlist

### Vendors
- Explore featured vendors
- Browse the complete vendors list

### Profile
- Display user information
- View name, email, and avatar
- Logout and clear the authentication session

## Navigation

The application includes a bottom navigation bar with four main sections:

- Home
- Category
- Wishlist
- Profile

## Authentication Flow

```text
Splash Screen
    ↓
Check Supabase Session
    ↓
 ┌──────────────┐
 │ Logged In?   │
 └──────────────┘
   ↙        ↘
 Yes          No
  ↓            ↓
 Home       Sign In
               ↓
       ┌───────┴────────┐
       ↓                ↓
    Sign Up       Forgot Password
```

## Tech Stack

- Flutter *(if used for implementation)*
- Supabase Authentication
- Supabase backend services



## Contributors

- Chebbah Hadil
