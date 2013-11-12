define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'SyllabusController',
        ($scope, $location, $routeParams, Restangular, Course, Syllabus) ->

            if($routeParams.hasOwnProperty('courseId'))
                Course.get(Number($routeParams.courseId)).then (course) ->
                    $scope.course = course

                    if _.isNumber($scope.course.syllabus)
                        Syllabus.get($scope.course.syllabus).then (syllabus) ->
                            $scope.original_syllabus = syllabus
                            $scope.syllabus = Restangular.copy(syllabus)
                    else
                        $scope.original_syllabus = $scope.course.syllabus
                        $scope.syllabus = Restangular.copy($scope.course.syllabus)

            $scope.undo = ->
                $scope.syllabus = Restangular.copy($scope.original_syllabus)

            $scope.save = ->
                console.log "Saving syllabus changes: ", $scope.syllabus
                Syllabus.update($scope.syllabus)
                    .then (result) ->
                        console.log "Save worked: ", result
                        $scope.course.syllabus = result
                        $location.path("/Course/#{$scope.course.id}")
                    .catch (err) ->
                        console.log "Save failed: ", err
