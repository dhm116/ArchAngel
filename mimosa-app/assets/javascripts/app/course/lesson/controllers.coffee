define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'LessonController',
        ($scope, $routeParams, $location, Restangular, User, Course, Lesson, Assignment, Forum) ->
            # Keep track of what model we're loading
            params = _.last($routeParams.resources)

            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})

            $scope.resource = params.resource

            Course.get(Number(courseParams.id)).then (course) ->
                $scope.course = course
                Course.isInstructorFor(course.id).then (isInstructor) ->
                    $scope.isInstructor = isInstructor

            $scope.action = lessonParams.action[0].toUpperCase() + lessonParams.action[1..-1]
            $scope.moment = moment

            unless lessonParams.action.indexOf('add') is 0
                Lesson.get(Number(lessonParams.id)).then (lesson) ->
                    $scope.lesson = lesson
                    $scope.assignments = []

                    if $scope.lesson.assignments.length
                        Assignment.all($scope.lesson.assignments).then (assignments) ->
                            $scope.assignments = assignments


                    if $scope.lesson.forums.length > 0
                        Forum.all($scope.lesson.forums).then (forums) ->
                            $scope.forums = forums

            else if lessonParams.action.indexOf('add') is 0
                $scope.lesson = {course:courseParams.id, author: User.data.id}

            # if($routeParams.hasOwnProperty('action'))
            #     if $routeParams.action is 'edit'

            $scope.undo = ->
                if $scope.original_lesson
                    $scope.lesson = Restangular.copy($scope.original_lesson)

            $scope.save = ->
                if lessonParams.action.indexOf("edit") is 0
                    console.log "Saving lesson changes: ", $scope.lesson
                    Lesson.update($scope.lesson)
                        .then (result) ->
                            console.log "Save worked: ", result
                            # $scope.course.lessons.push result
                            $location.path("/course/view/#{$scope.course.id}/lesson/view/#{result.id}")
                        .catch (err) ->
                            console.log "Save failed: ", err
                else if lessonParams.action.indexOf('add') is 0
                    console.log "Saving new Lesson: ", $scope.lesson
                    Lesson.add($scope.lesson)
                        .then (result) ->
                            console.log "Adding worked: ", result
                            # $scope.lessons.push result
                            $scope.course.lessons.push(result.id)
                            $location.path("/course/view/#{$scope.course.id}/lesson/view/#{result.id}")
                        .catch (err) ->
                            console.log "Adding failed: ", err
