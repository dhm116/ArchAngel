define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'CourseController',
        ($scope, $routeParams, Restangular, User, Course, CourseSection, CourseRoster, Syllabus, Lesson, Team, Forum) ->

            # Keep track of what model we're loading
            # (not sure why...)
            params = _.last($routeParams.resources)

            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            sectionParams = _.findWhere($routeParams.resources, {resource:'section'})

            # We'll assume we're trying to load a specific
            # course
            courseId = Number(courseParams.id)

            $scope.resource = courseParams.resource

            # But if not, the course id should be defined
            # as the route parentId parameter
            # if courseParams.resource.indexOf('course')
            #     courseId = Number($routeParams.parentId)
            #     $scope.resource = 'course'

            # If we haven't already defined the list of
            # courses for this scope
            #
            # This may only be necessary to filter the
            # list of courses a user participates in
            unless $scope.courses
                # Load all of the courses
                Course.all().then (courses) ->
                    $scope.courses = courses

            # Define an empty syllabus object so we don't
            # have any null references
            $scope.syllabus = {}

            # Load the desired course defined in the courseId
            Course.get(courseId).then (course) ->
                # Set our scope reference to the course
                $scope.course = course

                # Check if the current user is an instructor for
                # this course
                Course.isInstructorFor($scope.course.id).then (isInstructor) ->
                    $scope.isInstructor = isInstructor

                # Load the syllabus for this course
                Syllabus.get($scope.course.syllabus).then (syllabus) ->
                    $scope.syllabus = syllabus

                # Create an empty list of lessons to avoid any
                # null references
                $scope.lessons = []

                # Only attempt to load lessons for this course
                # if there are any
                if $scope.course.lessons.length > 0
                    Lesson.all($scope.course.lessons).then (lessons) ->
                        $scope.lessons = lessons

                if $scope.course.forums.length > 0
                    Forum.all($scope.course.forums).then (forums) ->
                        $scope.forums = forums

                # Create an empty list of sections and section
                # members to avoid any null references
                $scope.sections = []
                $scope.section_members = []

                # Only attempt to load sections and members if
                # there are any
                if $scope.course.sections.length > 0
                    # Load all of the course sections defined for this
                    # course
                    CourseSection.all($scope.course.sections).then (sections) ->
                        $scope.sections = sections

                        # If the user hasn't selected a specific section
                        unless sectionParams
                            # We need to combine all of the roster references
                            # into a single list to load
                            rosterIds = []
                            rosterIds.push section.members for section in $scope.sections

                            # This flattens the array to keep it as a
                            # single dimension
                            rosterIds = _.flatten(rosterIds)

                            # Retrieve just the roster entries that belong
                            # to the student group
                            CourseRoster.students(rosterIds).then (members) ->
                                # This is our list of student roster objects
                                $scope.section_members = members

                                # Load the actual user data for each student
                                # in our section members list
                                #
                                # Pluck out just the user parameter, as that
                                # is the reference to the user id
                                User.all(_.pluck(members, 'user')).then (students) ->
                                    $scope.students = students

                            # We need to combine all of the team references
                            # into a single list to load
                            teamIds = []

                            teamIds.push section.teams for section in $scope.sections

                            # This flattens the array to keep it as a
                            # single dimension
                            teamIds = _.flatten(teamIds)

                            Team.all(teamIds).then (teams) ->

                                $scope.teams = teams

                        # The user has selected a specific section
                        else
                            # Get this section based on the id passed in the
                            # url (we need to parse the string version)
                            CourseSection.get(Number(sectionParams.id)).then (section) ->
                                $scope.section = section

                                # Load the students for this section
                                CourseRoster.students($scope.section.members).then (members) ->
                                    $scope.section_members = members

                                    # Load the actual user data for each student
                                    # in our section members list
                                    #
                                    # Pluck out just the user parameter, as that
                                    # is the reference to the user id
                                    User.all(_.pluck(members, 'user')).then (students) ->
                                        $scope.students = students

                                # Load the teams for this section
                                Team.all($scope.section.teams).then (teams) ->
                                    $scope.teams = teams

