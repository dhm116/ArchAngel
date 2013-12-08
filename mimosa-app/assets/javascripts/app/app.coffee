define ['angular', 'templates', 'app/mobile-check'], (angular, templates, mobilecheck) ->
    # ##Angular Configuration
    # Here is where we configure default parameters for `Restangular`
    angular.module('configuration', ['restangular','ngStorage'])
        .config (RestangularProvider) ->
            RestangularProvider.setRequestSuffix '/?format=json'
        .constant('BASE_URL', {
            local: 'http://localhost:8000'
            cloud: 'http://django-archangel.rhcloud.com'
        })
        # When the application runs, set a few other configuration
        # parameters based on what's in `$localStorage`
        .run (Restangular, $localStorage, BASE_URL, editableOptions) ->
            Restangular.setBaseUrl if $localStorage.useLocalData then BASE_URL.local else BASE_URL.cloud
            editableOptions.theme = 'bs3'

    # ##ArchAngel angular modules
    # Here we define our `djangoApp.services` module namespace,
    # along with any angular libraries we want to be available
    # for dependency injection.
    angular.module('djangoApp.services', ['configuration', 'ngStorage'])
    # Here is our controller namespace. There are many more angular
    # libraries available for dependency injection because our controllers
    # are much more involed in interacting with the DOM.
    angular.module('djangoApp.controllers', ['restangular', 'djangoApp.services', 'configuration', 'ngStorage', 'angularFileUpload'])
    # And, finally, we define the root `djangoApp` namespace with any
    # angular libraries we would like to make available.
    return angular.module('djangoApp', ['ngRoute', 'angularMoment','djangoApp.controllers','chieffancypants.loadingBar','btford.markdown', 'zj.namedRoutes', 'ngSanitize', 'xeditable', 'angular-growl', 'ngAnimate', 'truncate'])
