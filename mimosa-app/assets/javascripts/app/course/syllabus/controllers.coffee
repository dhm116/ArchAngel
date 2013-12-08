define ['angular'], (angular) ->
    # ##Syllabus controller
    return angular.module('djangoApp.controllers').controller 'SyllabusController',
        ($scope, $location, $routeParams, Restangular, Course, Syllabus) ->
            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            syllabusParams = _.findWhere($routeParams.resources, {resource:'syllabus'})

            Course.get(Number(courseParams.id)).then (course) ->
                $scope.course = course

            Syllabus.get(Number(syllabusParams.id)).then (syllabus) ->
                $scope.original_syllabus = syllabus
                $scope.syllabus = Restangular.copy(syllabus)

            # Helper method for discarding any changes made in the UI form
            $scope.undo = ->
                $scope.syllabus = Restangular.copy($scope.original_syllabus)

            # Helper method for saving the syllabus changes
            $scope.save = ->
                console.log "Saving syllabus changes: ", $scope.syllabus
                Syllabus.update($scope.syllabus)
                    .then (result) ->
                        console.log "Save worked: ", result
                        $location.path("/course/view/#{$scope.course.id}")
                    .catch (err) ->
                        console.log "Save failed: ", err
