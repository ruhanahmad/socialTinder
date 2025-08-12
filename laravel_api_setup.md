# Laravel API Setup Guide

## Overview
This guide provides instructions for setting up the Laravel backend API that replaces the Firebase services in the Social Tinder application. The API handles authentication, data storage, and file uploads that were previously managed by Firebase.

## Prerequisites
- PHP 8.1 or higher
- Composer
- MySQL or PostgreSQL database
- Laravel knowledge

## Installation Steps

### 1. Create a new Laravel project
```bash
composer create-project laravel/laravel social-tinder-api
cd social-tinder-api
```

### 2. Configure the database
Update the `.env` file with your database credentials:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=social_tinder
DB_USERNAME=root
DB_PASSWORD=your_password
```

### 3. Set up authentication
Install Laravel Sanctum for API token authentication:
```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

### 4. Create necessary models and migrations
```bash
php artisan make:model User -m
php artisan make:model Profile -m
php artisan make:model DatingMatch -m
php artisan make:model Restaurant -m
php artisan make:model SocialPost -m
php artisan make:model Event -m
php artisan make:model Message -m
```

### 5. Create API controllers
```bash
php artisan make:controller API/AuthController
php artisan make:controller API/ProfileController
php artisan make:controller API/DatingController
php artisan make:controller API/RestaurantController
php artisan make:controller API/SocialController
php artisan make:controller API/EventController
php artisan make:controller API/ChatController
```

### 6. Set up file storage
Configure Laravel's file storage for profile photos and other uploads:
```bash
php artisan storage:link
```

Update your `.env` file:
```
FILESYSTEM_DISK=public
```

## API Endpoints

Implement the following API endpoints to match the functionality in the Flutter app:

### Authentication
- `POST /api/register` - Register a new user
- `POST /api/login` - Login and get auth token
- `POST /api/logout` - Logout and invalidate token

### Profile
- `GET /api/profile` - Get user profile
- `POST /api/profile` - Update user profile
- `POST /api/profile/upload-photo` - Upload profile photo

### Dating
- `GET /api/dating/matches` - Get potential matches
- `POST /api/dating/like/{userId}` - Like a user
- `POST /api/dating/dislike/{userId}` - Dislike a user

### Restaurants
- `GET /api/restaurants` - Get list of restaurants
- `GET /api/restaurants/{id}` - Get restaurant details

### Social
- `GET /api/social/posts` - Get social posts
- `POST /api/social/posts` - Create a new post
- `POST /api/social/posts/upload-photo` - Upload post photo

### Events
- `GET /api/events` - Get list of events
- `GET /api/events/{id}` - Get event details

### Chat
- `GET /api/chat/matches` - Get user's matches for chat
- `GET /api/chat/messages/{matchId}` - Get messages for a match
- `POST /api/chat/messages/{matchId}` - Send a message

## Security Considerations

1. Implement proper authentication middleware for all protected routes
2. Validate all incoming requests
3. Implement rate limiting for API endpoints
4. Use HTTPS in production
5. Sanitize user inputs to prevent SQL injection and XSS attacks

## Deployment

For production deployment:

1. Set up a production server (AWS, DigitalOcean, etc.)
2. Configure a web server (Nginx, Apache)
3. Set up SSL certificates
4. Configure environment variables for production
5. Run database migrations

```bash
php artisan migrate --force
```

## Testing the API

You can test the API endpoints using tools like Postman or Insomnia before connecting the Flutter app.

## Connecting Flutter App

In the Flutter app, update the `apiBaseUrl` in all controller files to point to your Laravel API endpoint:

```dart
final String apiBaseUrl = 'https://your-laravel-api.com/api';
```

Replace `https://your-laravel-api.com/api` with your actual API URL.