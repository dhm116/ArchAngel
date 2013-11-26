define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentController',
        ($scope, $routeParams, $location, Restangular, User, Course, Lesson, Assignment, AssignmentSubmission) ->
            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})
            assignmentParams = _.findWhere($routeParams.resources, {resource:'assignment'})

            $scope.action = assignmentParams.action[0].toUpperCase() + assignmentParams.action[1..-1]

            Dropzone.discover()

            # console.log AWS.config.credentials
            $scope.aws = AWS.config.credentials

            # Load the desired course defined in the courseId
            Course.get(Number(courseParams.id)).then (course) ->
                # Set our scope reference to the course
                $scope.course = course

            Lesson.get(Number(lessonParams.id)).then (lesson) ->
                $scope.lesson = lesson
                Course.isInstructorFor(lesson.course).then (isInstructor) ->
                    $scope.isInstructor = isInstructor

            unless assignmentParams.action.indexOf('add') is 0
                Assignment.get(Number(assignmentParams.id)).then (assignment) ->
                    $scope.assignment = assignment
                    $scope.submissions = []

                    # Gather all user submissions for the assignment
                    if $scope.assignment.submissions.length
                        AssignmentSubmission.all($scope.assignment.submissions).then (submissions) ->
                            $scope.submissions = submissions

                            User.all(_.pluck(submissions, 'author')).then (students) ->
                                $scope.students = _.indexBy(students, 'id')

                                console.log $scope.students


            else if assignmentParams.action.indexOf('add') is 0
                $scope.assignment = {lesson:lessonParams.id, author: User.data.id}

            $scope.undo = ->
                if $scope.original_assignment
                    $scope.assignment = Restangular.copy($scope.original_assignment)

            $scope.save = ->
                if assignmentParams.action.indexOf('edit') is 0
                    console.log "Saving assignment changes: ", $scope.assignment
                    Assignment.update($scope.assignment)
                        .then (result) ->
                            console.log "Save worked: ", result
                            # $scope.course.lesson.assignments.push result
                            $location.path("/course/view/#{$scope.course.id}/lesson/view/#{$scope.lesson.id}/assignment/view/#{result.id}")
                        .catch (err) ->
                            console.log "Save failed: ", err
                else if assignmentParams.action.indexOf('add') is 0
                    console.log "Saving new Assignment: ", $scope.assignment
                    Assignment.add($scope.assignment)
                        .then (result) ->
                            console.log "Adding worked: ", result
                            # $scope.lesson.assignments.push result
                            $scope.lesson.assignments.push(result.id)
                            $location.path("/course/view/#{$scope.course.id}/lesson/view/#{$scope.lesson.id}/assignment/view/#{result.id}")
                        .catch (err) ->
                            console.log "Adding failed: ", err
