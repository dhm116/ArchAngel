define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'CourseController',
        ($scope, $routeParams, Restangular, User, Course, CourseSection, CourseRoster, Syllabus, Lesson) ->
            # console.log "Course Controller", $routeParams
            $scope.resource = $routeParams.resource
            unless $scope.courses
                Course.all().then (courses) ->
                    $scope.courses = courses

            if($routeParams.hasOwnProperty('id'))
                Course.get(Number($routeParams.id)).then (course) ->
                    $scope.course = course
                    Course.isInstructorFor($scope.course.id).then (isInstructor) ->
                        $scope.isInstructor = isInstructor

                    # $scope.sections = []
                    # $scope.section_members = []
                    # if $scope.course.sections.length > 0
                    #     CourseSection.all($scope.course.sections).then (sections) ->
                    #         $scope.sections = sections

                    #         CourseRoster.all($scope.sections.members).then (members) ->
                    #             $scope.section_members = members
                    #             checkInstructorGroup()
                    # else
                    #     checkInstructorGroup()

                    Syllabus.get($scope.course.syllabus).then (syllabus) ->
                        $scope.syllabus = syllabus

                    # lessonIds = (if _.isNumber(item) then item else item.id for item in $scope.course.lessons)
                    $scope.lessons = []
                    if $scope.course.lessons.length > 0
                        Lesson.all($scope.course.lessons).then (lessons) ->
                            $scope.lessons = lessons

            # Restangular.all('upcoming-assignments').getList().then (items) ->
            #     $scope.upcomingAssignments = items
