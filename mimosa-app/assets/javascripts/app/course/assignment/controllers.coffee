define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentController',
        ($scope, $routeParams, Restangular, Course, Lesson, Assignment) ->

            if($routeParams.hasOwnProperty('assignmentId'))
                Assignment.get(Number($routeParams.assignmentId)).then (assignment) ->
                    $scope.assignment = assignment[0]
