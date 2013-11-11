define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'SyllabusController',
        ($scope, $routeParams, Restangular, Course, Syllabus) ->

            if($routeParams.hasOwnProperty('courseId'))
                Course.get(Number($routeParams.courseId)).then (course) ->
                    $scope.course = course

                    if _.isNumber($scope.course.syllabus)
                        Syllabus.get($scope.course.syllabus).then (syllabus) ->
                            $scope.original_syllabus = syllabus
                            $scope.syllabus = _.clone(syllabus)

            $scope.undo = ->
                $scope.syllabus = _.clone($scope.original_syllabus)

            $scope.save = ->
                Syllabus.update($scope.syllabus)
                    .then (result) ->
                        console.log "Save worked: ", result
                    .catch (err) ->
                        console.log "Save failed: ", err
