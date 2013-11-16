define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'CourseController',
        ($scope, $routeParams, Restangular, User, Course, CourseSection, CourseRoster, Syllabus, Lesson, Team) ->

            $scope.resource = $routeParams.resource
            courseId = Number($routeParams.id)
            if $routeParams.resource.indexOf('course')
                courseId = Number($routeParams.parentId)
                $scope.resource = 'course'

            unless $scope.courses
                Course.all().then (courses) ->
                    $scope.courses = courses

            $scope.syllabus = {}

            Course.get(courseId).then (course) ->
                $scope.course = course
                Course.isInstructorFor($scope.course.id).then (isInstructor) ->
                    $scope.isInstructor = isInstructor

                console.log "Syllabus id = ", $scope.course.syllabus
                Syllabus.get($scope.course.syllabus).then (syllabus) ->
                    $scope.syllabus = syllabus
                    console.log $scope.syllabus

                $scope.lessons = []
                if $scope.course.lessons.length > 0
                    Lesson.all($scope.course.lessons).then (lessons) ->
                        $scope.lessons = lessons

                $scope.sections = []
                $scope.section_members = []
                if $scope.course.sections.length > 0
                    CourseSection.all($scope.course.sections).then (sections) ->
                        $scope.sections = sections

                        unless $routeParams.resource.indexOf('section') isnt -1
                            CourseRoster.students($scope.sections.members).then (members) ->
                                $scope.section_members = members
                                User.all(_.pluck(members, 'user')).then (students) ->
                                    $scope.students = students

                            Team.all($scope.sections.teams).then (teams) ->
                                $scope.teams = teams
                        else
                            CourseSection.get(Number($routeParams.id)).then (section) ->
                                $scope.section = section

                                CourseRoster.students($scope.section.members).then (members) ->

                                    $scope.section_members = members

                                    User.all(_.pluck(members, 'user')).then (students) ->
                                        $scope.students = students

                                Team.all($scope.section.teams).then (teams) ->
                                    $scope.teams = teams

