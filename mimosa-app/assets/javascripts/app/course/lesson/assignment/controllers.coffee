define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentController',
        ($scope, $routeParams, $location, $sce, $upload, Restangular, User, Course, Lesson, Assignment, AssignmentSubmission) ->
            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})
            assignmentParams = _.findWhere($routeParams.resources, {resource:'assignment'})

            $scope.action = assignmentParams.action[0].toUpperCase() + assignmentParams.action[1..-1]
            $scope.moment = moment

            $('#dueDate').datetimepicker({
                pickTime: false
                autoclose: true
                # format: 'yyyy-mm-ddThh:mm' #"dd MM yyyy - hh:ii"
            }).on 'changeDate', (ev) ->
                $scope.assignment.due_date = ev.date

            # console.log AWS.config.credentials
            $scope.aws = AWS.config.credentials
            # console.log $scope.aws
            bucket = new AWS.S3 {params: {Bucket: 'archangel'}}

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

                    $scope.assignmentsubmission = {author: User.data.id, assignment: assignment.id}

                    # Gather all user submissions for the assignment
                    if $scope.assignment.submissions.length
                        AssignmentSubmission.all($scope.assignment.submissions).then (submissions) ->
                            $scope.submissions = submissions
                            # console.log submissions

                            User.all(_.pluck(submissions, 'author')).then (students) ->
                                $scope.students = _.indexBy(students, 'id')


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

            $scope.onFileSelect = (files) ->
                $scope.assignmentsubmission.file = files[0]

            $scope.saveSubmission = () ->
                #bucket.getSignedUrl 'putObject', {Key: "#{User.data.id}/#{new Date().getTime()}/${filename}"}, (err, url) =>
                createSubmission = () ->
                    # submission = {
                    #     author: User.data.id
                    #     assignment: $scope.assignment.id
                    #     name: "#{User.data.first_name} #{User.data.last_name}'s submission (see attached)"
                    #     file_path: "https://s3.amazonaws.com/archangel/#{filename}"
                    # }

                    AssignmentSubmission.add($scope.assignmentsubmission)
                        .then (result) ->
                            $scope.submissions.push(result)
                            $scope.assignment.submissions.push(result.id)
                        .catch (err) ->
                            console.log err
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
