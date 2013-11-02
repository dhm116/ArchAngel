define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'CourseController', ($scope, Restangular, Course) ->
        # $scope.user = User
        # Restangular.setBaseUrl 'http://macpro.local:8000/'
        # getAllData(Restangular, $scope, 'users')
        # getAllData(Restangular, $scope, 'courses')
        $scope.allCourses = ->
            console.log Course
            return Course.courses
        $scope.getCourse = (id) ->
            return Course.get(id)
