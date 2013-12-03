define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'TeamController',
        ($scope, $routeParams, $location, Restangular, User, Course, CourseSection, CourseRoster, Syllabus, Lesson, Team, TeamMember, Forum) ->

            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            teamParams = _.findWhere($routeParams.resources, {resource:'team'})

            $scope.action = teamParams.action[0].toUpperCase() + teamParams.action[1..-1]
            $scope.moment = moment
            $scope._ = _
            $scope.User = User

            if courseParams
                # We'll assume we're trying to load a specific
                # course
                courseId = Number(courseParams.id)

                # Load the desired course defined in the courseId
                Course.get(courseId).then (course) ->
                    # Set our scope reference to the course
                    $scope.course = course

                    # Check if the current user is an instructor for
                    # this course
                    Course.isInstructorFor($scope.course.id).then (isInstructor) ->
                        $scope.isInstructor = isInstructor

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
                            $scope.sections = _.indexBy(sections, 'id')

                            Team.all().then (teams) ->
                                if teamParams.action.indexOf('add') is 0
                                    if teams.length
                                        teams = _.groupBy(teams, 'section')

                                    waitingFor = sections.length - 1

                                    finishedAdding = () ->
                                        console.log waitingFor
                                        if waitingFor == 0
                                            Team.all(null, true).then (teams) ->
                                                TeamMember.all(null, true).then (members) ->
                                                    $location.path("/course/view/#{$scope.course.id}")
                                        else
                                            waitingFor -= 1

                                    for section in sections
                                        team_no = if teams.hasOwnProperty(section.id) then _.last(teams[section.id]).team_no + 1 else 1
                                        team = {
                                            section: section.id
                                            team_no: team_no
                                            name: "S#{section.section_no}.#{team_no}"
                                        }
                                        Team.add(team)
                                            .then (result) ->
                                                console.log "Adding worked: ", result
                                                # $scope.lessons.push result
                                                $scope.sections[result.section].teams.push(result.id)
                                            .catch (err) ->
                                                console.log "Adding failed: ", err
                                            .finally () ->
                                                finishedAdding()
                                else if teamParams.action.indexOf('delete') is 0
                                    team = _.findWhere(teams, {id: Number(teamParams.id)})
                                    Team.delete(team).finally () ->
                                        Team.all(null, true).then (teams) ->
                                            TeamMember.all(null, true).then (members) ->
                                                $location.path("/course/view/#{$scope.course.id}")
                    else
                        # $scope.$broadcast 'error', {error: {}}
            else
                Course.all().then (courses) ->
                    $scope.courses = courses
                    $scope.isInstructorFor = {}
                    for course in courses
                        preserveCourse = (course) ->
                            Course.isInstructorFor(course.id).then (result) ->
                                $scope.isInstructorFor[course.id] = result
                        preserveCourse(course)

                User.all().then (users) ->
                    $scope.users = _.indexBy(users, 'id')


