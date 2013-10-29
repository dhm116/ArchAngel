require
    urlArgs: "b=#{(new Date()).getTime()}"
    paths:
        jquery: 'vendor/jquery/jquery'
        angular: 'vendor/angular/angular'
        # views: 'app/example-view'
    ,['templates', 'app/mobile-check']
    ,(templates, mobilecheck) ->
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

        app = angular.module('djangoApp', [
                'ngRoute'
                'djangoApp.controllers'
                'chieffancypants.loadingBar'
            ]
            , ($routeProvider, $locationProvider) ->
                console.log angular.$rootScope
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

        app.config ($httpProvider) ->
            console.log $httpProvider.defaults.headers
            # delete $httpProvider.defaults.headers.common["X-Requested-With"]
            # delete $httpProvider.defaults.headers.post["Content-type"]

        angular.module('djangoApp.controllers', ['restangular'])
            .controller 'ArchangelController', ($scope, Restangular) ->
                $scope.isMobile = isMobile

                Restangular.setBaseUrl 'http://macpro.local:8000/'
                Restangular.setRequestSuffix '/?format=json'

                getAllData(Restangular, $scope, 'users')
                getAllData(Restangular, $scope, 'courses')

            .controller 'CourseController', ($scope, $route, $routeParams, $location, Restangular) ->
                Restangular.one('courses', $routeParams.courseId).get().then (course) ->
                    $scope.course = course

            .controller 'StudentController', ($scope, $route, $routeParams, $location, Restangular) ->
                getAllData(Restangular, $scope, 'students')

            .controller 'LoginController', ($scope, $route, $routeParams, $location, $http, Restangular) ->
                $scope.login = ->
                    $http.post(
                        'http://localhost:8000/api-token-auth/',
                        $scope.user
                    ).then (response) ->
                        console.log response
        # app.config ['$routeProvider', '$locationProvider'],

        # app.controller 'CourseController', ['restangular'], ($scope, $http, $params, $location, Restangular) ->
        #     Restangular.

        angular.bootstrap document, ['djangoApp']
