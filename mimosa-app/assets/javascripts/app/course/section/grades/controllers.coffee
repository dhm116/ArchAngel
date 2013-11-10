define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'GradeController', ($scope, $routeParams, Restangular, Course, CourseSection, Grade) ->
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

                CourseSection.get(course.sections).then (sections) ->
                    $scope.sections = sections
                    if($routeParams.hasOwnProperty('sectionId'))
                        $scope.section = _.findWhere(sections, {id: Number($routeParams.sectionId)})
						
						Grade.get(section.grades).then (grades) ->
							$scope.grades = grades
