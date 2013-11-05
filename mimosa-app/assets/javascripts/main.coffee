require.config
    paths:
        angular: 'vendor/angular/angular'
    baseUrl: 'javascripts'
    shim:
        'angular': {'exports':'angular'}
    priority: ['angular']

require
    #urlArgs: "b=#{(new Date()).getTime()}"
    paths:
        jquery: 'vendor/jquery/jquery'
    #     angular: 'angular'
    #     # views: 'app/example-view'
    ,[
        'angular'
        'templates'
        'app/mobile-check'
    ]
    ,(angular, templates, mobilecheck) ->
        $(document).foundation()

        $.get ''

        token = null

        isMobile = mobilecheck.isMobile()

        getAllData = (service, $scope, resource) ->
            service.all(resource).getList().then (items) ->
                $scope[resource] = items

        getTemplate = (name) ->
            template = templates[name]

            if isMobile and templates.hasOwnProperty("#{name}_mobile")
                template = templates["#{name}_mobile"]
            return template

        angular.module('configuration', [])
            .constant('BASE_URL', 'http://0.0.0.0:8000') #'http://django-archangel.rhcloud.com')

        angular.module('djangoApp.services', ['configuration'])
        angular.module('djangoApp.controllers', ['restangular', 'djangoApp.services', 'configuration', 'ngStorage'])
            .config (RestangularProvider, BASE_URL) ->
                RestangularProvider.setBaseUrl "#{BASE_URL}/" #'http://django-archangel.rhcloud.com/'
                RestangularProvider.setRequestSuffix '/?format=json'

        require [
            'app/login/services'
            'app/login/controllers'
            'app/course/services'
            'app/course/controllers'
        ], ->
            app = angular.module('djangoApp', [
                    'ngRoute'
                    'ngCookies'
                    'djangoApp.controllers'
                    'chieffancypants.loadingBar'
                    'ngStorage'
                ]
                , ($routeProvider, $locationProvider) ->
                    $routeProvider.when '/login', {
                            template: templates['login']
                            controller: 'LoginController'
                    }
                    $routeProvider.when '/Course/:courseId', {
                            template: templates['course-main']
                            controller: 'CourseController'
                    }
                    $routeProvider.when '/Students', {
                            template: templates['students']
                            controller: 'StudentController'
                    }
                    $routeProvider.otherwise {
                            template: getTemplate('main-screen') #templates['main-screen']
                            controller: 'ArchangelController'
                    }
                    $locationProvider.html5Mode(true)
            )

            angular.module('djangoApp.controllers') #, ['restangular', 'djangoApp.services'])
                .controller 'NavbarController', ($scope, Restangular, User, Course) ->
                    $scope.isMobile = isMobile
                    $scope.user = User
                    $scope.courses = Course.courses
                #    console.log Course.courses

                .controller 'ArchangelController', ($scope, Restangular, User) ->
                    $scope.isMobile = isMobile
                    # $scope.user = User
                    # Restangular.setBaseUrl 'http://macpro.local:8000/'
                    getAllData(Restangular, $scope, 'users')
                    # getAllData(Restangular, $scope, 'courses')

                # .controller 'CourseController', ($scope, $route, $routeParams, $location, Restangular) ->
                #     Restangular.one('courses', $routeParams.courseId).get().then (course) ->
                #         $scope.course = course

                .controller 'StudentController', ($scope, $route, $routeParams, $location, Restangular) ->
                    getAllData(Restangular, $scope, 'students')

                # .controller 'LoginController', ($scope, $http, User) ->
                #     $scope.login = ->
                #         # $http.post(
                #         #     'http://django-archangel.rhcloud.com/api-token-auth/',
                #         #     $scope.user
                #         # ).then (response) ->
                #         #     console.log response
                #         console.log User.isAuthenticated()
                #         unless User.isAuthenticated()
                #             User.login $scope.user, (result) ->
                #                 unless result
                #                     console.log 'Invalid username/password'
                #                 else
                #                     console.log 'Logged in'
                #         else
                #             console.log "#{User.getName()} is already logged in"

            # app.config ['$routeProvider', '$locationProvider'],

            # app.controller 'CourseController', ['restangular'], ($scope, $http, $params, $location, Restangular) ->
            #     Restangular.

            angular.bootstrap document, ['djangoApp']
