define ['angular', 'templates', 'app/mobile-check'], (angular, templates, mobilecheck) ->
    # console.log angular, templates, mobilecheck
    angular.module('configuration', ['restangular','ngStorage'])
        .config (RestangularProvider) ->
            RestangularProvider.setRequestSuffix '/?format=json'
        .constant('BASE_URL', {
            local: 'http://localhost:8000'
            cloud: 'http://django-archangel.rhcloud.com'
        })
        .run (Restangular, $localStorage, BASE_URL, editableOptions) ->
            Restangular.setBaseUrl if $localStorage.useLocalData then BASE_URL.local else BASE_URL.cloud #"#{BASE_URL}/" #'http://django-archangel.rhcloud.com/'
            editableOptions.theme = 'bs3'

    angular.module('djangoApp.services', ['configuration', 'ngStorage'])
    angular.module('djangoApp.controllers', ['restangular', 'djangoApp.services', 'configuration', 'ngStorage', 'angularFileUpload'])
    return angular.module('djangoApp', ['ngRoute', 'angularMoment','djangoApp.controllers','chieffancypants.loadingBar','btford.markdown', 'zj.namedRoutes', 'ngSanitize', 'xeditable', 'angular-growl', 'ngAnimate'])
