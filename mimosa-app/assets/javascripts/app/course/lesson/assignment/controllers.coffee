define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'AssignmentController',
        ($scope, $routeParams, $location, $sce, Restangular, User, Course, Lesson, Assignment, AssignmentSubmission) ->
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

            # bucket.getSignedUrl 'putObject', {Key: 'testKey'}, (err, url) =>
            #     if err
            #         console.log err
            #     else
            #         #$scope.signedURL = $sce.trustAsResourceUrl(url)
            #         $('#assignmentDropzone').attr('action', _.unescape(url))
            #         console.log url
            #         Dropzone.discover()

            Dropzone.options.assignmentDropzone = {
                autoProcessQueue: false

                init: ->
                    @on "addedfile", (file) =>
                        console.log file
                        bucket.getSignedUrl 'putObject', {Key: "#{User.data.id}/#{new Date().getTime()}/${filename}"}, (err, url) =>
                            if err
                                console.log err
                            else
                                #$scope.signedURL = $sce.trustAsResourceUrl(url)
                                # $('#assignmentDropzone').attr('action', _.unescape(url))
                                console.log url
                                @options.url = url
                                @enqueueFile(file)
                                @processQueue()

                        # Create the remove button
                        removeButton = Dropzone.createElement("<button class='btn btn-sm btn-block'>Remove file</button>")

                        # Listen to the click event
                        removeButton.addEventListener "click", (e) =>
                            # Make sure the button click doesn't submit the form:
                            e.preventDefault();
                            e.stopPropagation();

                            # Remove the file preview.
                            @removeFile(file);
                            # If you want to the delete the file on the server as well,
                            # you can do the AJAX request here.

                        # Add the button to the file preview element.
                        file.previewElement.appendChild(removeButton);
                    @on 'sending', (file, xhr, data) =>
                        console.log arguments
            }
            Dropzone.discover()


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
