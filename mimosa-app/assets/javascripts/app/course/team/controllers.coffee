define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'TeamController',
        ($scope, $routeParams, $location, $q, Restangular, User, Course, CourseSection, CourseRoster, Syllabus, Lesson, Team, TeamMember, Forum) ->

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
                Course.all().then (courses) ->
                    $scope.courses = courses
                    $scope.isInstructorFor = {}
                    for course in courses
                        preserveCourse = (course) ->
                            Course.isInstructorFor(course.id).then (result) ->
                                $scope.isInstructorFor[course.id] = result
                        preserveCourse(course)

                    CourseSection.all().then (sections) ->
                        $scope.sections = _.indexBy(sections, 'id')
                        $scope.course_sections = _.groupBy(sections, 'course')

                        Team.all().then (teams) ->
                            $scope.teams = _.indexBy(teams, 'id')
                            $scope.section_teams = _.groupBy(teams, 'section')
                            $scope.course_teams = _.groupBy(teams, 'course')

                            TeamMember.all().then (teamMembers) ->
                                $scope.team_members = _.groupBy(teamMembers, 'team')

                                User.all().then (users) ->
                                    $scope.users = _.indexBy(users, 'id')
                                    $scope.courseTeamReportData course for course in courses
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
                        names = []
                        if members
                            for member in members
                                user = $scope.users[member.user]
                                names.push "#{user.first_name} #{user.last_name}"

                        data.push {section: section, team: team, members: names}
                $scope.teamReport[course.id] = data
                return $scope.teamReport[course.id]

            $scope.createTeam = (course) ->
                sections = []
                section_members = []

                defer = $q.defer()

                # Only attempt to load sections and members if
                # there are any
                if course.sections.length > 0
                    # Load all of the course sections defined for this
                    # course
                    console.log 'Loading course sections'
                    CourseSection.all(course.sections).then (sections) ->
                        sections = _.indexBy(sections, 'id')

                        console.log 'Loading any existing teams'
                        Team.all().then (teams) ->
                            console.log 'Got existing teams', teams
                            if teams.length
                                teams = _.groupBy(teams, 'section')

                            waitingFor = _.size(sections) - 1

                            console.log "We'll need to wait for #{waitingFor} sections to finish adding teams to"

                            finishedAdding = () ->
                                console.log "Waiting for #{waitingFor} sections to finish adding"
                                if waitingFor == 0
                                    Team.all(null, true).then (teams) ->
                                        TeamMember.all(null, true).then (members) ->
                                            defer.resolve({teams: teams, members: members})
                                            # $location.path("/course/view/#{course.id}")
                                else
                                    waitingFor -= 1

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

            $scope.deleteTeam = (team) ->
                defer = $q.defer()
                Team.delete(team).finally () ->
                    Team.all(null, true).then (teams) ->
                        TeamMember.all(null, true).then (members) ->
                            defer.resolve({teams: teams, members: members})
                return defer.promise


