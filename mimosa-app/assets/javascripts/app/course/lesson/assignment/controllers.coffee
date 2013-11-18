define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentController',
        ($scope, $routeParams, Restangular, Course, Lesson, Assignment) ->
            console.log $routeParams
            if($routeParams.hasOwnProperty('parentId'))
                Lesson.get(Number($routeParams.parentId)).then (lesson) ->
                    $scope.lesson = lesson
                    Course.get($scope.lesson.course).then (course) ->
                        $scope.course = course

            if($routeParams.hasOwnProperty('id'))
                Assignment.get(Number($routeParams.id)).then (assignment) ->
                    $scope.assignment = assignment
            # console.log assignment
