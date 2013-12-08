define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Course', ($q, $rootScope, Restangular, CourseSection, CourseRoster, Lesson, Assignment, User) ->
        # ##Course service
        class Course extends ServiceBase
            model: 'courses'

            __onNewInstance: () =>
                # Make sure all local data is removed when the user
                # logs out.
                $rootScope.$on 'logout', () =>
                    console.log "Detected user logout event, deleting data"
                    @items = []

            # Helper method for identifying if the current user is
            # an instructor for the course with the matching `courseId` .
            isInstructorFor: (courseId) =>
                defer = @$q.defer()
                @get(courseId).then (course) =>
                    # Check and see if we've already determined this.
                    if course.hasOwnProperty('isInstructor')
                        defer.resolve(course.isInstructor)
                    else
                        # Make sure this course actually has some sections
                        # defined.
                        if course.sections.length > 0
                            # Load all of the course sections for this course.
                            CourseSection.all(course.sections).then (sections) ->
                                # Load the course rosters as well.
                                CourseRoster.all(sections.members).then (members) ->
                                    # Try to find the current user in the roster for any
                                    # section and find out if they have an `instructor` role.
                                    if members.length > 0 and _.findWhere(members, {course: courseId, user:User.data.id, group: 'instructor'})
                                        course.isInstructor = true
                                    else
                                        course.isInstructor = false
                                    defer.resolve(course.isInstructor)
                return defer.promise

            # **Note**: We're not currently using this method
            upcomingAssignments: (courseId) =>
                defer = @$q.defer()

                @get(courseId).then (course) =>
                    if course.lessons.length > 0
                        Lesson.all(course.lessons).then (lessons) =>
                            assignmentIds = _.flatten(_.pluck(lessons, 'assignments'))

                            if assignmentIds.length > 0
                                Assignment.all(assignmentIds).then (assignments) =>
                                    upcoming = []
                                    upcoming.push assignment for assignment in assignments when moment(assignment.due_date) >= moment() and moment().diff(moment(assignment.due_date), 'weeks') <= 1
                                    defer.resolve(upcoming)
                            else
                                defer.resolve([])
                    else
                        defer.resolve([])

                return defer.promise
        return new Course(Restangular, $q, $rootScope)
