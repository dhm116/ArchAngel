# Getting started

1. After installing `django`, `python` and `psycopg2`, also install `django_evolution`, `model_utils` and `rest_framework`
2. Update the [settings.py](archangel/settings.py) file and change the database connection parameters
3. Either run `python manage.py syncdb` (if you have no tables created in the database) or `python manage.py evolve --hint --execute` to alter your existing tables with any updates
4. Run `python manage.py runserver 0.0.0.0:8000` to start the server
5. You *may* need to add some content through the admin interface or via the REST service for the web application to work properly