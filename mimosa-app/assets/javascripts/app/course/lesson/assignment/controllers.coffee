define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentController',
        ($scope, $routeParams, $location, Restangular, User, Course, Lesson, Assignment, AssignmentSubmission) ->
            # Get course, lesson, and assignment information from parameters in the URL
            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})
            assignmentParams = _.findWhere($routeParams.resources, {resource:'assignment'})

            $scope.action = assignmentParams.action[0].toUpperCase() + assignmentParams.action[1..-1]
            $scope.moment = moment

            $('#dueDate').datetimepicker({
                pickTime: false
                autoclose: true
            }).on 'changeDate', (ev) ->
                $scope.assignment.due_date = ev.date

            # File upload
            $scope.aws = AWS.config.credentials
            bucket = new AWS.S3 {params: {Bucket: 'archangel'}}

            # Load the desired course defined in the courseId
            Course.get(Number(courseParams.id)).then (course) ->
                # Set our scope reference to the course
                $scope.course = course

            # Load the desired lesson defined in the lessonId
            Lesson.get(Number(lessonParams.id)).then (lesson) ->
                $scope.lesson = lesson
                # Check if the user is the instructor of the course
                Course.isInstructorFor(lesson.course).then (isInstructor) ->
                    $scope.isInstructor = isInstructor

            # As long as user is not adding a lesson
            unless assignmentParams.action.indexOf('add') is 0
                Assignment.get(Number(assignmentParams.id)).then (assignment) ->
                    $scope.assignment = assignment
                    $scope.submissions = []

                    $scope.assignmentsubmission = {author: User.data.id, assignment: assignment.id}

                    # Gather all user submissions for the assignment
                    if $scope.assignment.submissions.length
                        AssignmentSubmission.all($scope.assignment.submissions).then (submissions) ->
                            $scope.submissions = submissions

                            # Get the assignment submission author's first and last name
                            User.all(_.pluck(submissions, 'author')).then (students) ->
                                $scope.students = _.indexBy(students, 'id')

            # Instructor wants to add an assignment
            else if assignmentParams.action.indexOf('add') is 0
                # Set assignment parameters (lesson, author) in the scope
                $scope.assignment = {lesson:lessonParams.id, author: User.data.id}

            # If user elected to undo their work
            $scope.undo = ->
                if $scope.original_assignment
                    $scope.assignment = Restangular.copy($scope.original_assignment)

            # If user elected to save the assignment
            $scope.save = ->
                # If they are editing an existing assignment, save the changes
                if assignmentParams.action.indexOf('edit') is 0
                    console.log "Saving assignment changes: ", $scope.assignment
                    Assignment.update($scope.assignment)
                        .then (result) ->
                            console.log "Save worked: ", result
                            $location.path("/course/view/#{$scope.course.id}/lesson/view/#{$scope.lesson.id}/assignment/view/#{result.id}")
                        .catch (err) ->
                            console.log "Save failed: ", err
                # If they are adding a new assignment, save the assignment and its corresponding information
                else if assignmentParams.action.indexOf('add') is 0
                    console.log "Saving new Assignment: ", $scope.assignment
                    Assignment.add($scope.assignment)
                        .then (result) ->
                            console.log "Adding worked: ", result
                            $scope.lesson.assignments.push(result.id)
                            $location.path("/course/view/#{$scope.course.id}/lesson/view/#{$scope.lesson.id}/assignment/view/#{result.id}")
                        .catch (err) ->
                            console.log "Adding failed: ", err

            # If submission was selected, set the file in the scope
            $scope.onFileSelect = (files) ->
                $scope.assignmentsubmission.file = files[0]

            # User elects to save assignment submision
            $scope.saveSubmission = () ->
                createSubmission = () ->

                    # Add assignment submission
                    AssignmentSubmission.add($scope.assignmentsubmission)
                        .then (result) ->
                            $scope.submissions.push(result)
                            $scope.assignment.submissions.push(result.id)
                        .catch (err) ->
                            console.log err
                # If there is an attachment to upload, prepare to upload to the server
                if $scope.assignmentsubmission.file
                    file = $scope.assignmentsubmission.file

                    filename = "#{$scope.assignmentsubmission.author}/#{new Date().getTime()}/#{file.name}"
                    bucket.putObject(
                        {
                            Key: filename
                            ContentType: file.type
                            Body: file
                        }
                        ,(err, data) ->
                            if err
                                console.log err
                            else
                                $scope.assignmentsubmission.file_path = "https://s3.amazonaws.com/archangel/#{filename}"
                                delete $scope.assignmentsubmission.file
                                createSubmission()
                    )
                else
                    createSubmission()

            # User elects to delete assignment submission
            $scope.deleteSubmission = (submission) ->
                console.log $scope.submissions
                delete $scope.submissions[_.indexOf($scope.submissions, submission)]
                console.log $scope.submissions
                console.log $scope.assignment.submissions
                delete $scope.assignment.submissions[_.indexOf($scope.assignment.submissions, submission.id)]
                console.log $scope.assignment.submissions
                AssignmentSubmission.delete(submission)
                    .then (result) ->
                        console.log result
                    .catch (err) ->
                        console.log error
                        $scope.submissions.push(submission)
                        $scope.assignment.submissions.push(submission.id)
