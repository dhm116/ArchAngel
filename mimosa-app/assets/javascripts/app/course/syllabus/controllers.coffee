define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'SyllabusController',
        ($scope, $location, $routeParams, Restangular, Course, Syllabus) ->
            # console.log "Syllabus Controller", $routeParams
            Course.get(Number($routeParams.parentId)).then (course) ->
                $scope.course = course

            if Number($routeParams.id?)
                Syllabus.get(Number($routeParams.id)).then (syllabus) ->
                    $scope.original_syllabus = syllabus
                    $scope.syllabus = Restangular.copy(syllabus)

            $scope.undo = ->
                $scope.syllabus = Restangular.copy($scope.original_syllabus)

            $scope.save = ->
                console.log "Saving syllabus changes: ", $scope.syllabus
                Syllabus.update($scope.syllabus)
                    .then (result) ->
                        console.log "Save worked: ", result
                        # $scope.course.syllabus = result
                        # $scope.syllabus = result
                        $location.path("/course/view/#{$scope.course.id}")
                    .catch (err) ->
                        console.log "Save failed: ", err
