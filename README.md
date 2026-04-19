# Tap2Save

Tap2Save is an iOS savings app built with UIKit and Firebase. The main idea of the app is to help users save money by creating separate "jars" for different goals and adding savings amounts over time.

This project was developed as a student-style app to practice:
- iOS development with Swift and UIKit
- Storyboard navigation
- Firebase Authentication
- Firebase Firestore database operations
- CRUD-style features for user data and jars

## Project Overview

The app allows a user to:
- create an account
- log in with email and password
- view a welcome dashboard
- see their total saved balance
- create savings jars with a goal amount
- add savings entries into a selected jar
- view jar details
- delete jars
- manage some profile details
- toggle dark mode

The app uses Firebase Authentication for login and Firestore for storing user and jar data.

## Features

### Authentication
- Sign up with name, last name, email, and password
- Log in with email and password
- Sign out from the profile screen

### Home Screen
- Displays a welcome message using the user's name
- Shows the total saved amount across all jars
- Formats money values as currency, for example `$2,000.00`

### Jars
- Create a new jar with:
  - jar name
  - savings goal
- View all jars in a table view
- Open a jar detail screen
- Delete an existing jar with swipe-to-delete

### Jar Details
- View:
  - jar name
  - current balance
  - savings goal

### Savings Entries
- Add a new savings amount to a selected jar
- Save the amount into Firestore under `entryLog`
- Automatically update the jar balance
- Show a confirmation alert after a successful save
- Redirect the user to the jars tab after saving
- Show a goal reached alert when the jar reaches its target

### Profile
- View current user name and email
- Edit:
  - name
  - email
  - password
- Email updates use Firebase's verification-first flow
- Toggle dark mode using `UserDefaults`

### Data Management
- Delete all jars and savings entries
- Delete the full account and data

## Tech Stack

- Language: Swift
- UI Framework: UIKit
- Navigation: Storyboard segues and `UITabBarController`
- Backend: Firebase
- Authentication: Firebase Auth
- Database: Cloud Firestore
- Local persistence: `UserDefaults` for dark mode

## Project Structure

Main folders in the project:

- `Views/`
  - view controllers and UI-related classes
- `Models/`
  - app data models such as `User` and `Jar`
- `Managers/`
  - shared service classes
- `Controllers/Auth/`
  - helper functions related to auth and Firestore creation logic
- `Base.lproj/`
  - storyboard and launch screen

## Important Files

- `AppDelegate.swift`
  - configures Firebase when the app launches

- `SceneDelegate.swift`
  - applies the saved theme when the app starts

- `ViewController.swift`
  - login screen

- `Views/NewAccountVC.swift`
  - account creation screen

- `Views/HomeVC.swift`
  - dashboard screen with welcome message and total saved amount

- `Views/JarsVC.swift`
  - lists all jars and allows deleting a jar

- `Views/JarDetailsVC.swift`
  - shows jar information

- `Views/NewSaveVC.swift`
  - adds a new saving entry to a selected jar

- `Views/ProfileVC.swift`
  - profile screen with dark mode and navigation to account management

- `Views/EditProfileVC.swift`
  - lets the user update profile information

- `Views/DataManagement.swift`
  - delete data and delete account logic

## Firebase Data Structure

Based on the current code, Firestore is structured like this:

```text
users
  └── {uid}
      ├── name
      ├── lastName
      ├── email
      └── jars
          └── {jarId}
              ├── name
              ├── balance
              ├── goal
              ├── date
              └── entryLog
                  └── {entryId}
                      ├── amount
                      └── date
```

## How to Run the Project

### Requirements
- macOS
- Xcode
- Apple Simulator or physical iPhone/iPad
- Firebase project configured for the app

### Steps

1. Open the project in Xcode:

```text
Tap2Save.xcodeproj
```

2. Make sure Swift Package dependencies resolve correctly.

The project uses Firebase packages such as:
- FirebaseAuth
- FirebaseFirestore
- FirebaseDatabase

3. Check that `GoogleService-Info.plist` is included in the project.

4. Choose a simulator or device.

5. Build and run the app.

## Firebase Notes

This project already includes a `GoogleService-Info.plist` file, which means a Firebase project has already been connected.

For email changes:
- Firebase may require the new email to be verified first
- Firebase may also require recent login for sensitive operations

## Current Functionality Summary

The current version of the app supports:
- authentication
- jar creation
- jar listing
- jar deletion
- savings entry creation
- balance updates
- total savings calculation
- profile editing
- dark mode
- full account/data deletion

## Known Limitations

Some limitations or areas for improvement in the current project:
- no edit jar feature yet
- no savings history screen visible to the user
- no automated tests included
- some validation and error handling could be improved further
- some older helper files are still present even though newer logic exists in the view controllers

## Learning Goals of This Project

This project helped practice:
- connecting an iOS app to Firebase
- using Firestore collections and subcollections
- passing data between screens
- working with UIKit table views
- handling user input and alerts
- implementing simple app settings like dark mode
- building a small but complete CRUD-style mobile application

## Author

Created as an iOS student project for learning and assessment purposes.
