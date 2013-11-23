define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentController',
        ($scope, $routeParams, Restangular, Course, Lesson, Assignment) ->
            # console.log $routeParams

            Lesson.get(Number($routeParams.parentId)).then (lesson) ->
                $scope.lesson = lesson
                Course.isInstructorFor(lesson.course).then (isInstructor) ->
                    $scope.isInstructor = isInstructor

            unless $routeParams.action.indexOf('add') is 0
                Lesson.get(Number($routeParams.id)).then (assignment) ->
                    $scope.assignment = assignment

            else if $routeParams.action.indexOf('add') is 0
                $scope.assignment = {course:$routeParams.parentId, author: User.data.id}

            $scope.undo = ->
                if $scope.original_assignment
                    $scope.lesson = Restangular.copy($scope.original_assignment)

            $scope.save = ->
                if $routeParams.action.indexOf('edit') is 0
                    console.log "Saving lesson changes: ", $scope.assignment
                    Assignment.update($scope.assignment)
                        .then (result) ->
                            console.log "Save worked: ", result
                            # $scope.course.lesson.assignments.push result
                            $location.path("/course/view/#{$scope.course.id}/lesson/view/#{$scope.lesson.id}/assignment/view/#{result.id}")
                        .catch (err) ->
                            console.log "Save failed: ", err
                else if $routeParams.action.indexOf('add') is 0
                    console.log "Saving new Assignment: ", $scope.assignment
                    Assignment.add($scope.assignment)
                        .then (result) ->
                            console.log "Adding worked: ", result
                            # $scope.lesson.assignments.push result
                            $scope.course.lesson.assignments.push(result.id)
                            $location.path("/course/view/#{$scope.course.id}/lesson/view/#{$scope.lesson.id}/assignment/view/#{result.id}")
                        .catch (err) ->
                            console.log "Adding failed: ", err