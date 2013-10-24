require
    urlArgs: "b=#{(new Date()).getTime()}"
    paths:
        jquery: 'vendor/jquery/jquery'
        angular: 'vendor/angular/angular'
        # views: 'app/example-view'
    ,   ['templates']
    ,    (templates) ->
        $(document).foundation()

        $.get ''

        getAllData = (service, $scope, resource) ->
            service.all(resource).getList().then (items) ->
                $scope[resource] = items

        app = angular.module('djangoApp', [
                'ngRoute'
                'djangoApp.controllers'
                'chieffancypants.loadingBar'
            ]
            , ($routeProvider, $locationProvider) ->
                $routeProvider.when '/Course/:courseId', {
                        template: templates['course-main']
                        controller: 'CourseController'
                }
                $routeProvider.otherwise {
                        template: templates['main-screen']
                        controller: 'ArchangelController'
                }
                $locationProvider.html5Mode(true)
        )

        angular.module('djangoApp.controllers', ['restangular'])
            .controller 'ArchangelController', ($scope, Restangular) ->
                Restangular.setBaseUrl 'http://macpro.local:8000/'
                Restangular.setRequestSuffix '/?format=json'

                getAllData(Restangular, $scope, 'users')
                getAllData(Restangular, $scope, 'courses')

            .controller 'CourseController', ($scope, $route, $routeParams, $location, Restangular) ->
                Restangular.one('courses', $routeParams.courseId).get().then (course) ->
                    $scope.course = course
                    $scope.name = "testing"

        # app.config ['$routeProvider', '$locationProvider'],

        # app.controller 'CourseController', ['restangular'], ($scope, $http, $params, $location, Restangular) ->
        #     Restangular.

        angular.bootstrap document, ['djangoApp']
