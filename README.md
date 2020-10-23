# MatchUS (Alpha)
An IOS app that matches people based on preferences and interests.

Please run the application on IPhone 11 Pro Max for testing.

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
- Programmed the Google places API and integrated it with the locations view controller.
- Programmed the interests page and the logic where only a select amount of interests can be added

### Jinho Yoon (25%)
- Designed the entire base of the UI and added Swift code snippets for custom properties
- Programmed segues and passed data between view controllers
- Programmed the table view logic for the interests view controller

### Taehyoung Kim (25%)
- Integrated Apple login and registration
- Programmed the login and registration page client-side logic

### Pravat Bhusal (25%)
- Setup the Django backend and SQLite server
- Programmed the login and register API endpoints using the Django User authentication model
- Programmed API requests from the client to the server to store or login user information

# Deviations
- Planned to allow the Apple login/registration to connect with the backend, but since this was a unique way of doing OAuth we found it difficult. This is planned to be done for the Beta release using another API endpoint to register Apple users.
- Planned on authenticating user in the registration view controller, but instead the user was authenticated at the end of the onboarding (at the interests view controller). This is planned to be changed for the Beta release using a new API endpoint.
- Planned on having the X button in the interests view controller table cell outside of the cell background, but we pivoted the design to include the button inside to simplify the design
