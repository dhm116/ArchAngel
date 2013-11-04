define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'CourseController', ($scope, $routeParams, Restangular, Course) ->
        # $scope.user = User
        # Restangular.setBaseUrl 'http://macpro.local:8000/'
        # getAllData(Restangular, $scope, 'users')
        # getAllData(Restangular, $scope, 'courses')
        Course.all().then (courses) ->
            $scope.courses = courses

        if($routeParams.hasOwnProperty('courseId'))
            Course.get(Number($routeParams.courseId)).then (course) ->
                $scope.course = course
