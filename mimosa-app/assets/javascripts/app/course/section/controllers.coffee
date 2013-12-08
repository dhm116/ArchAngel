define ['angular'], (angular) ->
    # ##Course section controller
    # This controller is not currently used
    return angular.module('djangoApp.controllers').controller 'CourseSectionController', ($scope, $routeParams, Restangular, Course, CourseSection) ->

        Course.all().then (courses) ->
            $scope.courses = courses

        if($routeParams.hasOwnProperty('courseId'))
            Course.get(Number($routeParams.courseId)).then (course) ->
                $scope.course = course

                CourseSection.get(course.sections).then (sections) ->
                    $scope.sections = sections
                    if($routeParams.hasOwnProperty('sectionId'))
                        $scope.section = _.findWhere(sections, {id: Number($routeParams.sectionId)})
