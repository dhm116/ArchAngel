define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentController',
        ($scope, $routeParams, Restangular, Course, Lesson, Assignment) ->

            if($routeParams.hasOwnProperty('lessonId'))
                Lesson.get(Number($routeParams.lessonId)).then (lesson) ->
                    $scope.lesson = lesson
                    Course.get($scope.lesson.course).then (course) ->
                        $scope.course = course

            if($routeParams.hasOwnProperty('assignmentId'))
                Assignment.get(Number($routeParams.assignmentId)).then (assignment) ->
                    $scope.assignment = assignment
            console.log assignment
