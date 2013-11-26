define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentSubmissionController',
        ($scope, $routeParams, Restangular, User, Course, Lesson, Assignment, AssignmentSubmission) ->

            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})
            assignmentParams = _.findWhere($routeParams.resources, {resource:'assignment'})
            submissionParams = _.findWhere($routerParams.resources, {resource:'submission'})

            # Load the desired course defined in the courseId
            Course.get(Number(courseParams.id)).then (course) ->
                # Set our scope reference to the course
                $scope.course = course

            # Load the desired lesson defined in the lessonId
            Lesson.get(Number(lessonParams.id)).then (lesson) ->
                # Set our scope reference to the lesson
                $scope.lesson = lesson

            # Load the desired assignment defined in the assignmentId
            Assignment.get(Number(assignmentParams.id)).then (asssignment) ->
                # Set our scope reference to the assignment
                $scope.assignment = assignment

            # Load the desired submission defined in the submissionId
            AssignmentSubmission.get(Number(submissionParams.id)).then (submission) ->
                # Set our scope reference to the submission
                $scope.submission = submission