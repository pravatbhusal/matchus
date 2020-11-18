Group number: 7  
Team members: Pravat Bhusal, Taehyoung Kim, Andrew Le, Jinho Yoon  
Name of project: MatchUs  
Dependencies: Xcode 12.2, Swift 5  

# Special Instructions:
Please open this README.md file in a Markdown renderer.

You must first run the Django web server and web socket.  
1. Go inside of the server folder and run ```pip install -r requirements.txt``` for Python v3.8.6.  
2. cd into the server/server directory, then run the migrations using ```python manage.py makemigrations```. 
3. Then migrate using ```python manage.py migrate```.  
4. Lastly, run the server using ```python manage.py runserver```.  

Next, you need to run the Xcode simulator and register an account .  
1. Inside the client folder, run ```pod install``` to install the podfile dependencies.  
2. Now open the Matchus.xcworkspace file with Xcode.  
3. Run the app on an IPhone 11 Pro Max simulator on Xcode.  
4. The app will load the landing page, click the "Register" button and fill out the form to register your account.

Once you are finished registering your account, you will be directed to the dashboard page. The dashboard page will be empty if there's no users near your
location. Therefore, to test the dashboard out we need to register more users.

Log out of the current user by clicking Profile Icon in the bottom tab bar. Then click the "Go to Settings" button, click "Account settings" button, then click the "Logout" button. You'll now be redirected to the home page, so create another account at a nearby location of the first user. Once this new user is created, if the account is close enough to the other user in terms of latitude/longitude, then it will show the other user on the dashboard.

To test chatting with another user, you need two simulators open. One simulator is the first user, and the other simulator is the other user. The chat system works
in real-time because it uses web sockets.

# Contributions
Table generated using https://www.tablesgenerator.com/markdown_tables.

| Feature | Description | Release planned | Release actual | Deviations (if any) | Who/Percentage worked on |
|---------|-------------|-----------------|----------------|---------------------|--------------------------|
|         |             |                 |                |                     |                          |
|         |             |                 |                |                     |                          |
|         |             |                 |                |                     |                          |
