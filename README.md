# Food Recipe App

A Flutter-based recipe sharing application with user authentication, recipe management, and image hosting capabilities.

## Requirements

### System Requirements
- **Flutter**: 3.6.0 or higher
- **Dart**: 3.6.0 or higher
- **Android**: API level 21 or higher
- **iOS**: 11.0 or higher

### Development Environment Setup

1. Install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Verify installation:
   ```bash
   flutter --version
   dart --version
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```

## Architecture Overview

### Step 1: Authentication & User Data Management

Authentication is implemented using **Firebase Auth** with email/password credentials. User profile data (name, bio, profile image) is stored in **Firestore**, while images are uploaded to **Cloudinary**.

**Firebase Setup:**
- User authentication handled through Firebase Authentication
- User collections created in Firestore with the following fields:
  - `uid`: User unique identifier
  - `name`: User's display name
  - `email`: User's email address
  - `bio`: User biography
  - `photoUrl`: Profile image URL (from Cloudinary)
  - `createdAt`: Account creation timestamp

**Recipe Collection:**
- Recipe documents stored in Firestore with fields matching the Recipe data model:
  - `id`: Recipe unique identifier
  - `title`: Recipe name
  - `description`: Recipe description
  - `imageUrl`: Recipe image URL (from Cloudinary)
  - `cuisine`: Cuisine type
  - `difficulty`: Difficulty level (Easy, Medium, Hard)
  - `cookingTime`: Cooking duration in minutes
  - `servings`: Number of servings
  - `ingredients`: List of ingredients
  - `steps`: Cooking instructions
  - `authorId`: Recipe creator's user ID
  - `authorName`: Recipe creator's name
  - `authorPhotoUrl`: Recipe creator's profile image
  - `likesCount`: Number of likes
  - `savedCount`: Number of saves
  - `createdAt`: Recipe creation timestamp

### Step 2: Global State Management

A **global HashMap** is used to maintain consistency throughout the app. This approach ensures:
- Single source of truth for recipe data across all screens
- Efficient data synchronization without redundant Firestore queries
- Reduced network calls and improved app performance
- Real-time updates across all UI components

**Implementation:**
- `HomeScreenController` maintains `globalRecipeMap` containing all recipes
- All screens reference this global map instead of making individual Firestore queries
- Search, filtering, and recipe operations work on the in-memory map
- Map is refreshed when recipes are created, updated, or deleted

### Step 3: Image Management with Cloudinary

**Cloudinary Integration** is used for image uploads and optimization:
- All images (recipe and profile) are uploaded to Cloudinary
- Image URLs are stored in Firestore for quick retrieval
- Unsigned uploads configured with preset: `recipe`
- Images organized in folders:
  - Recipe images: `food_recipe/recipes/`
  - Profile images: `food_recipe/profiles/`

**Image Upload Flow:**
1. User selects image from gallery or camera
2. Image is uploaded to Cloudinary using unsigned upload
3. Secure URL is returned from Cloudinary
4. URL is stored in Firestore (user profile or recipe document)
5. URL is cached in the global state for immediate display

**Cloudinary Configuration:**
- Cloud Name: `dvedswvf9`
- Upload Preset: `recipe`
- API Key: Configured in environment variables

## Key Features

- **User Authentication**: Email/password signup and login with Firebase
- **Recipe Management**: Create, read, update, and delete recipes
- **Image Upload**: Upload recipe and profile images to Cloudinary
- **Search & Filter**: Search recipes by title, cuisine, difficulty, and cooking time
- **User Profiles**: View and edit user profile with profile picture
- **Recipe Details**: View complete recipe with ingredients, steps, and author info
- **Like & Save**: Like and save favorite recipes
- **PDF Export**: Download recipes as PDF to device
- **Edit Recipes**: Update existing recipes with prefilled form fields

## Dependencies

Key packages used in this project:
- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: Database for user and recipe data
- `cloudinary_flutter`: Image upload and management
- `get`: State management and routing
- `image_picker`: Image selection from gallery/camera
- `pdf`: PDF generation
- `printing`: Print and share PDFs
- `path_provider`: File system access

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Create a Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add configuration files
4. Set up Cloudinary:
   - Create a Cloudinary account
   - Configure upload preset
   - Add credentials to `.env` file
5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── features/
│   ├── onboarding/          # Authentication screens
│   ├── home_screen/         # Home and recipe listing
│   ├── recipe_details/      # Recipe detail view
│   ├── add_recipe/          # Recipe creation/editing
│   ├── search_recipe/       # Search and filtering
│   └── user_profile/        # User profile management
├── models/                  # Data models
├── services/                # Business logic and API calls
├── routes/                  # Navigation configuration
└── utils/                   # Utilities and constants
```

## Notes

- The app uses GetX for state management and routing
- All images are hosted on Cloudinary for optimal performance
- Firestore is used as the primary database
- The global recipe map ensures consistent data across the app
