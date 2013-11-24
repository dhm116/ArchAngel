
define ['angular'], (angular) -> 
    return angular.module('djangoApp.controllers').controller 'GradesController',
        ($scope, $routeParams, $location, Restangular, User, Course, Lesson, Assignment, AssignmentSubmission, GradedAssignmentSubmission) ->

            Course.get(Number($routeParams.parentId)).then (course) ->
                $scope.course = course
                # shouldn't this check the section rather than the course itself?
                Course.isInstructorFor(course.id).then (isInstructor) ->
                    $scope.isInstructor = isInstructor

            $scope.action = $routeParams.action[0].toUpperCase() + $routeParams.action[1..-1]

			# Create an empty list of lessons to avoid any
            # null references
            $scope.lessons = []

            # Only attempt to load lessons for this course
             # if there are any
            if $scope.course.lessons.length > 0
            	Lesson.all($scope.course.lessons).then (lessons) ->
                	$scope.lessons = lessons

            # Create an empty list of sections and section
            # members to avoid any null references
            $scope.sections = []
            $scope.section_members = []

            # Only attempt to load sections and members if
            # there are any
            if $scope.course.sections.length > 0
                # Load all of the course sections defined for this course
                CourseSection.all($scope.course.sections).then (sections) ->
                    $scope.sections = sections

                    # If the user is an instructor
                    if $scope.isInstructor
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

                    # The user is a student
                    else
                       

# define ['angular'], (angular) ->
#     return angular.module('djangoApp.controllers').controller 'LessonController',
#         ($scope, $routeParams, $location, Restangular, User, Course, Lesson, Assignment) ->

#             Course.get(Number($routeParams.parentId)).then (course) ->
#                 $scope.course = course
#                 Course.isInstructorFor(course.id).then (isInstructor) ->
#                     $scope.isInstructor = isInstructor

#             $scope.action = $routeParams.action[0].toUpperCase() + $routeParams.action[1..-1]

#             $scope.lessons = []
#             $scope.assignments = []

#             # Only attempt to load lessons for this course
#             # if there are any
#             if $scope.course.lessons.length > 0
#                     Lesson.all($scope.course.lessons).then (lessons) ->
#                         $scope.lessons = lessons

                # loop through lessons for assignments        
                # if $scope.lesson.assignments.length > 0
                #         Assignment.all($scope.lesson.assignments).then (assignments) ->
                #             $scope.assignments = assignments

# student, author of assignment submission
# instructor, author of assignment