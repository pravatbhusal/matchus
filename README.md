# MatchUS (Alpha)
An IOS app that matches people based on preferences and interests.

DISCLAIMER: The app only supports the viewports of the IPhone 11 Pro Max.

### Tech Stack
Front-end uses Swift.  
Back-end uses Django.  
Database uses SQLite (apart of the Django REST framework).

### Run the client
Open the Matchus.xcworkspace and run the app in Xcode

### Run the server
The server is required in order for the client to send requests and handle server-side logic.

Please read the README.md file in the server folder to understand how to start the server.

# Contributions
### Andrew Le (25%)
1. Programmed the Dashboard front-end view and implemented lazy loading for the dashboard table
view.  
2. Programmed chat room view controller's keyboard avoiding view logic.  
3. Programmed segues from dashboard to the profile view.  

### Jinho Yoon (25%)
1. Programmed the entire UI in the storyboard and edited UI component properties to match the
Figma design.  
2. Programmed segues between view controllers for testing and production.  
3. Created the identity view controller UI and uploading data from the user's photo library.  

### Taehyoung Kim (25%)
1. Changed Apple authentication to use Google authentication.  
2. Programmed the profile view and implemented image downloading from the server for profiles.  
3. Loaded profile's name and photo UI front-end.  

### Pravat Bhusal (25%)
1. Programmed Django channels (websockets) to perform chat communication between two users.  
2. Programmed the chat view controller to load the relevant chats of a user.  
3. Programmed the chat room view controller to send chat messages between users.  
4. Installed the Starscream websocket client to communicate between users in the chat room.  
5. Programmed the Django endpoints necessary to create, read, update, and delete the chats and profile of the user.

# Deviations
1. We planned on using Apple authentication originally but as it turns out we needed to pay for a developers liscense, so we decided to go with Google OAuth instead.  
2. We didn't realize we needed a view controller to set the user's name and profile photo, so we ended up programming that in the onboarding section (when user registers).  
3. We wanted the user to be able to upload at least 4 images into their profile, but due to the phone screen size we decided to only go with 3.  
