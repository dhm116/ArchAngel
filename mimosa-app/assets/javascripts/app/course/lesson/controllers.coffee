define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'LessonController',
        ($scope, $routeParams, Restangular, Course, Lesson, Assignment) ->

            if($routeParams.hasOwnProperty('lessonId'))
                Lesson.get(Number($routeParams.lessonId)).then (lesson) ->
                    $scope.lesson = lesson
                    Course.get($scope.lesson.course).then (course) ->
                        $scope.course = course

                    if _.every($scope.lesson.assignments, _.isNumber)
                        Assignment.all($scope.lesson.assignments).then (assignments) ->
                            $scope.lesson.assignments = assignments
