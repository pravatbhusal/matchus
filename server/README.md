# Django Server
This is the server (API) for the app. This app uses Django 3.1.2.

First, install the dependencies in the requirements.txt file.

Second, run the migrations using ```python3 manage.py makemigrations```.

Third, migrate the database using ```python3 manage.py migrate```.

Lastly, to run the server, cd into the server folder and execute ```python3 manage.py runserver```.

You can follow this tutorial https://www.youtube.com/watch?v=263xt_4mBNc to better understand how Django works.

### Token Authentication
This medium article is how we'll program token based authentication for Django to work with the IOS client.

https://medium.com/quick-code/token-based-authentication-for-django-rest-framework-44586a9a56fb

### Word2Vec Model
MatchUs uses the Word2Vec model to map words into vectors and use them to rank interests between
users.

This GeeksforGeeks article explains how to use the model.

https://www.geeksforgeeks.org/python-word-embedding-using-word2vec/
