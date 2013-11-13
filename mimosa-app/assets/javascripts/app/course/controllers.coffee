define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'CourseController',
        ($scope, $routeParams, Restangular, User, Course, CourseSection, CourseRoster, Syllabus, Lesson) ->

            unless $scope.courses
                Course.all().then (courses) ->
                    $scope.courses = courses

            checkInstructorGroup = ->
                if $scope.course?.sections?.members?
                    $scope.isInstructor = if _.findWhere($scope.course.sections.members, {user:User.data.id, group: 'instructor'}) then true else false

            if($routeParams.hasOwnProperty('id'))
                Course.get(Number($routeParams.id)).then (course) ->
                    $scope.course = course

                    if _.every($scope.course.sections, _.isNumber)
                        CourseSection.all($scope.course.sections).then (sections) ->
                            $scope.course.sections = sections

                            CourseRoster.all($scope.course.sections.members).then (members) ->
                                $scope.course.sections.members = members
                                checkInstructorGroup()
                    else
                        checkInstructorGroup()

                    if _.isNumber($scope.course.syllabus)
                        Syllabus.get($scope.course.syllabus).then (syllabus) ->
                            $scope.course.syllabus = syllabus

                    if _.every($scope.course.lessons, _.isNumber)
                        Lesson.all($scope.course.lessons).then (lessons) ->
                            $scope.course.lessons = lessons

            # Restangular.all('upcoming-assignments').getList().then (items) ->
            #     $scope.upcomingAssignments = items
