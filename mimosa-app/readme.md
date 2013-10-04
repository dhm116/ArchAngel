# Getting started

1. You'll need to [install node](http://nodejs.org/)
2. You'll need to [install mimosa](http://mimosa.io) with `npm install -g mimosa`
3. Run `mimosa build` from within this project folder. This will download any server-side or client-side libraries you don't have.
4. Modify the [main.coffee](assets/javascripts/main.coffee) file and update the `Restangular.setBaseUrl` property to match your environment
5. Make sure you have the [django application](../django-app) running
6. Run `mimosa watch -s` to start a local server for development
