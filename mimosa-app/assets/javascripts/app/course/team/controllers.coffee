define ['angular'], (angular) ->
    # ##Team controller
    return angular.module('djangoApp.controllers').controller 'TeamController',
        ($scope, $routeParams, $location, $q, Restangular, User, Course, CourseSection, CourseRoster, Syllabus, Lesson, Team, TeamMember, Forum) ->
            # Pull out our URL parameters to load the appropriate models.
            courseParams = _.findWhere($routeParams.resources, {resource:'course'})
            teamParams = _.findWhere($routeParams.resources, {resource:'team'})

            # Humanize the action for our resource in case the user is
            # adding or editing an item.
            $scope.action = teamParams.action[0].toUpperCase() + teamParams.action[1..-1]
            # Provide the UI access to the `moment` and `_` libraries.
            $scope.moment = moment
            $scope._ = _
            $scope.User = User

            # Make sure our image placeholder service is running.
            Holder.run()

            # Helper method to make (re)loading the appropriate data
            # for constructing our team report.
            $scope.loadReportDataSources = () ->
                Course.all().then (courses) ->
                    $scope.courses = courses
                    $scope.isInstructorFor = {}
                    for course in courses
                        # Creating an in-line method for handing the
                        # promise returned helps ensure that we won't
                        # lose the reference to the course that the
                        # result is associated with.
                        preserveCourse = (course) ->
                            Course.isInstructorFor(course.id).then (result) ->
                                $scope.isInstructorFor[course.id] = result
                        preserveCourse(course)

                    CourseSection.all().then (sections) ->
                        $scope.sections = _.indexBy(sections, 'id')
                        $scope.course_sections = _.groupBy(sections, 'course')

                        CourseRoster.all().then (members) ->
                            $scope.section_members = _.groupBy(members, 'user')

                        Team.all().then (teams) ->
                            $scope.teams = _.indexBy(teams, 'id')
                            $scope.section_teams = _.groupBy(teams, 'section')
                            $scope.course_teams = _.groupBy(teams, 'course')

                            TeamMember.all().then (teamMembers) ->
                                $scope.team_members = _.groupBy(teamMembers, 'team')
                                $scope.member_teams = _.groupBy(teamMembers, 'user')

                                User.all().then (users) ->
                                    $scope.users = _.indexBy(users, 'id')
                                    $scope.courseTeamReportData course for course in courses

            # Helper method for assembling our team report data
            # from the various models.
            $scope.courseTeamReportData = (course) ->
                $scope.teamReport = {}
                unless $scope.teamReport
                    $scope.teamReport = {}

                if $scope.teamReport[course.id]
                    return $scope.teamReport[course.id]

                data = []
                for section in $scope.course_sections[course.id]
                    for team in $scope.section_teams[section.id]
                        members = $scope.team_members[team.id]
                        users = []
                        if members
                            for member in members
                                users.push $scope.users[member.user]

                        # We'll store our report data in a simplified
                        # model to make accessing information easier for
                        # each row in the report.
                        data.push {section: section, team: team, members: users}
                $scope.teamReport[course.id] = data
                return $scope.teamReport[course.id]

            # Helper method for creating a new team for the course
            # provided and ensuring the report data is refreshed
            # after the add is complete.
            $scope.createTeamAndReload = (course) ->
                $scope.createTeam(course).then () ->
                    $scope.loadReportDataSources()

            # Helper method for creating a new team for each section
            # in the course provided.
            $scope.createTeam = (course) ->
                sections = []
                section_members = []

                defer = $q.defer()

                # Only attempt to load sections and members if
                # there are any.
                if course.sections.length > 0
                    # Load all of the course sections defined for this
                    # course.
                    console.log 'Loading course sections'
                    CourseSection.all(course.sections).then (sections) ->
                        # Create an index of the sections for this course
                        # by `id` in case we need to quickly retrieve them.
                        sections = _.indexBy(sections, 'id')

                        console.log 'Loading any existing teams'
                        Team.all().then (teams) ->
                            console.log 'Got existing teams', teams
                            if teams.length
                                # Group the teams by their `section` to
                                # make retieving them easier.
                                teams = _.groupBy(teams, 'section')

                            # We'll keep track of how many sections we need
                            # to create a new team for, since it's an
                            # asynchronous operation and we'd like to know
                            # when everything is complete.
                            waitingFor = _.size(sections) - 1

                            console.log "We'll need to wait for #{waitingFor} sections to finish adding teams to"

                            # Each time a section has finished adding a new team,
                            # we'll decrement our countdown. When the countdown
                            # is complete, we'll reload all of the team data to
                            # make sure it shows up for the user.
                            finishedAdding = () ->
                                console.log "Waiting for #{waitingFor} sections to finish adding"
                                if waitingFor == 0
                                    Team.all(null, true).then (teams) ->
                                        TeamMember.all(null, true).then (members) ->
                                            defer.resolve({teams: teams, members: members})
                                else
                                    waitingFor -= 1

                            # Here is where we actually try to add the new team
                            # to the section.
                            addTeamToSection = (section, team) ->
                                Team.add(team)
                                    .then (result) ->
                                        console.log "Adding worked: ", result
                                        section.teams.push(result.id)
                                    .catch (err) ->
                                        console.log "Adding failed: ", err
                                        waitingFor -= 1
                                   .finally () ->
                                        finishedAdding()

                            # Loop through each section in this course and create
                            # the new team object. We use the `team_no` of the last team
                            # to determine what we should set ours as. Once the team
                            # object is ready, call `addTeamToSection`
                            for id, section of sections
                                console.log section
                                console.log "Adding a team to section #{section.section_no}"
                                team_no = if teams.hasOwnProperty(section.id) then _.last(teams[section.id]).team_no + 1 else 1
                                console.log "Adding team ##{team_no} to section #{section.section_no}"
                                addTeamToSection section, {
                                    section: section.id
                                    team_no: team_no
                                    name: "S#{section.section_no}.#{team_no}"
                                }
                else
                    defer.reject('No sections available')

                return defer.promise

            # Helper method for deleting the team and reloading the report
            # data when finished.
            $scope.deleteTeamAndReload = (team) ->
                $scope.deleteTeam(team).then () ->
                    $scope.loadReportDataSources()

            # Helper method for actually deleting the team.
            $scope.deleteTeam = (team) ->
                defer = $q.defer()
                Team.delete(team).finally () ->
                    Team.all(null, true).then (teams) ->
                        TeamMember.all(null, true).then (members) ->
                            defer.resolve({teams: teams, members: members})
                return defer.promise

            # Helper method for obtainig the team that the supplied user
            # belongs to for the supplied course.
            $scope.getMemberTeam = (user, course) ->
                if $scope.member_teams
                    member = _.findWhere($scope.member_teams[user], {course: course})
                    if member and $scope.teams
                        return $scope.teams[member.team]

            # Helper method for changing which team the supplied user
            # will be on for the supplied course.
            $scope.updateUserTeam = (data, course, user) ->
                teamMember = _.findWhere($scope.member_teams[user], {course: course})
                console.log teamMember
                if teamMember
                    teamMember.team = data.id
                    TeamMember.update(teamMember)
                        .then (result) ->
                            Team.all(null, true).then (teams) ->
                                TeamMember.all(null, true).then (members) ->
                                    $scope.loadReportDataSources()
                        .catch (err) ->
                            return "Error: " + err

            if courseParams
                # We'll assume we're trying to load a specific
                # course
                courseId = Number(courseParams.id)

                # Load the desired course defined in the courseId
                Course.get(courseId).then (course) ->
                    if teamParams.action.indexOf('add') is 0
                        console.log 'Got course to add teams to'
                        $scope.createTeam(course)
                            .then () ->
                                console.log 'Made the team!'
                                return true
                            .catch (err) ->
                                console.log 'Adding failed: ', err
                                $scope.$broadcast('warning', err)
                            .finally () ->
                                $location.path("/course/view/#{course.id}")
                    else if teamParams.action.indexOf('delete') is 0
                        teamId = Number(teamParams.id)

                        Team.get(teamId).then (team) ->
                            console.log 'Got team to delete', team
                            $scope.deleteTeam(team).then () ->
                                $location.path("/course/view/#{course.id}")

            else
                $scope.loadReportDataSources()

