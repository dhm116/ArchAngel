define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'CourseController',
        ($scope, $routeParams, Restangular, Course, CourseSection, Syllabus, Lesson) ->

            # $scope.user = User
            # Restangular.setBaseUrl 'http://macpro.local:8000/'
            # getAllData(Restangular, $scope, 'users')
            # getAllData(Restangular, $scope, 'courses')
            Course.all().then (courses) ->
                $scope.courses = courses

            if($routeParams.hasOwnProperty('courseId'))
                Course.get(Number($routeParams.courseId)).then (course) ->
                    $scope.course = course

                    CourseSection.get(course.sections).then (sections) ->
                        $scope.sections = sections
                        if($scope.sections.length is 1)
                            $scope.section = sections[0]
                        else if($routeParams.hasOwnProperty('sectionId'))
                            $scope.section = _.findWhere(sections, {id: Number($routeParams.sectionId)})

                    Syllabus.get(course.syllabus).then (syllabus) ->
                        $scope.course.syllabus = syllabus

                    Lesson.get(course.lessons).then (lessons) ->
                        $scope.course.lessons = lessons

            Restangular.all('upcoming-assignments').getList().then (items) ->
                $scope.upcomingAssignments = items
