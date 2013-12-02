define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Course', ($q, $rootScope, Restangular, CourseSection, CourseRoster, Lesson, Assignment, User) ->
        class Course extends ServiceBase
            model: 'courses'

            __onNewInstance: () =>
                $rootScope.$on 'logout', () =>
                    console.log "Detected user logout event, deleting data"
                    @items = []

            isInstructorFor: (courseId) =>
                defer = @$q.defer()
                @get(courseId).then (course) =>
                    if course.hasOwnProperty('isInstructor')
                        defer.resolve(course.isInstructor)
                    else
                        if course.sections.length > 0
                            CourseSection.all(course.sections).then (sections) ->

                                CourseRoster.all(sections.members).then (members) ->
                                    if members.length > 0 and _.findWhere(members, {course: courseId, user:User.data.id, group: 'instructor'})
                                        course.isInstructor = true
                                    else
                                        course.isInstructor = false
                                    defer.resolve(course.isInstructor)
                return defer.promise

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
        # class Course
        #     courses: []
        #     d: null

        #     constructor: ->

        #     all: () =>
        #         unless @d
        #             @d = $q.defer()

        #             unless @courses.length
        #                 Restangular.all('courses').getList().then (items) =>
        #                     @courses = items
        #                     # console.log "In async course service", @courses
        #                     console.log 'Getting list of courses'
        #                     @d.resolve(@courses)
        #             else
        #                 console.log 'Using cached course list'
        #                 console.log @courses
        #                 @d.resolve(@courses)

        #         return @d.promise

        #     get: (id) =>
        #         d = $q.defer()

        #         unless @courses.length
        #             @all().then (courses) =>
        #                 d.resolve(@__getCourse(id))
        #         else
        #             d.resolve(@__getCourse(id))
        #         return d.promise

        #     __getCourse: (id) =>
        #         return _.findWhere @courses, {id: id}

        # return new Course()
