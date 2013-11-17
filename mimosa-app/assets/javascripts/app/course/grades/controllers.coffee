define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'GradeController', ($scope, $routeParams, Restangular, Course, CourseSection, Submission, Grade) ->
        # $scope.user = User
        # Restangular.setBaseUrl 'http://macpro.local:8000/'
        # getAllData(Restangular, $scope, 'users')
        # getAllData(Restangular, $scope, 'courses')
		# getAllData(Restangular, $scope, 'grades')
        Course.all().then (courses) ->
            $scope.courses = courses

        if($routeParams.hasOwnProperty('courseId'))
            Course.get(Number($routeParams.courseId)).then (course) ->
                $scope.course = course

            Lesson.get(course.lessons).then (lessons) ->
                    $scope.lessons = lessons
                    if($routeParams.hasOwnProperty('lessonId'))
                        $scope.lesson = _.findWhere(lessons, {id: Number($routeParams.lessonId)})

                Assignment.get(lesson.assignments).then (assignments) ->
                    $scope.assignments = assignments
                    if($routeParams.hasOwnProperty('assignmentId'))
                        $scope.assignment = _.findWhere(assignments, {id: Number($routeParams.assignmentId)})

                Submission.get(assignment.submissions).then (submissions) ->
                    $scope.submissions = submissions
                    if($routeParams.hasOwnProperty('submissionId'))
                        $scope.submission = _.findWhere(submissions, {id: Number($routeParams.submissionId)})

                        Grade.get(submission.score).then (grades) ->
                            $scope.grades = grades
