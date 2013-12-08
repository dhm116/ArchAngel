define ['angular'], (angular) ->
    # ##Forum controller
    return angular.module('djangoApp.controllers').controller 'ForumController',
        ($scope, $routeParams, $location, Restangular, User, Course, Lesson, Forum) ->
            # Pull out our URL parameters to load the appropriate models.
            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})
            forumParams = _.findWhere($routeParams.resources, {resource:'forum'})

            Course.get(Number(courseParams.id)).then (course) ->
                $scope.course = course
                Course.isInstructorFor(course.id).then (isInstructor) ->
                    $scope.isInstructor = isInstructor

            if(lessonParams)
                Lesson.get(Number(lessonParams.id)).then (lesson) ->
                    $scope.lesson = lesson

            # Humanize the action for our resource in case the user is
            # adding or editing an item.
            $scope.action = forumParams.action[0].toUpperCase() + forumParams.action[1..-1]
            # Provide the UI access to the `moment` library.
            $scope.moment = moment

            # If we're not creating a new forum, load up the forum
            # specified in the URL.
            unless forumParams.action.indexOf('add') is 0
                Forum.get(Number(forumParams.id)).then (forum) ->
                    $scope.forum = forum

                    if forumParams.action.indexOf('edit') is 0
                        $scope.original_forum = Restangular.copy($scope.forum)

            else if forumParams.action.indexOf('add') is 0
                $scope.forum = {}

                if lessonParams
                    $scope.forum = {lesson: lessonParams.id}
                else
                    $scope.forum = {course: courseParams.id}

            # Helper method for discarding any changes made in the UI form
            $scope.undo = ->
                if $scope.original_forum
                    $scope.forum = Restangular.copy($scope.original_forum)

            # Helper method for saving the changes to the form.
            $scope.save = ->
                if forumParams.action.indexOf("edit") is 0
                    console.log "Saving forum changes: ", $scope.forum
                    Forum.update($scope.forum)
                        .then (result) ->
                            console.log "Save worked: ", result
                            # $scope.course.forums.push result
                            path = "/course/view/#{$scope.course.id}"
                            if(lessonParams)
                                path = "#{path}/lesson/view/#{$scope.lesson.id}"
                            $location.path("#{path}/forum/view/#{result.id}")
                        .catch (err) ->
                            console.log "Save failed: ", err
                else if forumParams.action.indexOf('add') is 0
                    console.log "Saving new forum: ", $scope.forum
                    Forum.add($scope.forum)
                        .then (result) ->
                            console.log "Adding worked: ", result
                            # $scope.forums.push result
                            path = "/course/view/#{$scope.course.id}"
                            if(lessonParams)
                                $scope.lesson.forums.push(result.id)
                                path = "#{path}/lesson/view/#{$scope.lesson.id}"
                            else
                                $scope.course.forums.push(result.id)
                            $location.path("#{path}/forum/view/#{result.id}")
                        .catch (err) ->
                            console.log "Adding failed: ", err

            # Helper method for deleting a forum
            $scope.delete = ->
                console.log "Attempting to delete a forum"
                forumId = $scope.forum.id
                path = "/course/view/#{$scope.course.id}"
                if(lessonParams)
                    path = "#{path}/lesson/view/#{$scope.lesson.id}"
                    delete $scope.lesson.forums[_.indexOf($scope.lesson.forums, forumId)]
                else
                    delete $scope.course.forums[_.indexOf($scope.course.forums, forumId)]

                # $location.path(path)
                Forum.delete($scope.forum)
                    .then (result) ->
                        console.log "Deleting worked: ", result
                        # path = "/course/view/#{$scope.course.id}"
                    .catch (err) ->
                        console.log "Deleting failed: ", err
                        # $location.path("#{path}/forum/view/#{forumId}")
                    .finally () ->
                        $location.path(path)
