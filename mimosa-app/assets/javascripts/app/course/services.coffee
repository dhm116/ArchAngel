define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Course', ($q, Restangular, CourseSection, CourseRoster, User) ->
        class Course extends ServiceBase
            model: 'courses'

            isInstructorFor: (courseId) =>
                defer = @$q.defer()
                @get(courseId).then (course) =>
                    if course.hasOwnProperty('isInstructor')
                        defer.resolve(course.isInstructor)
                    else
                        if course.sections.length > 0
                            CourseSection.all(course.sections).then (sections) ->

                                CourseRoster.all(sections.members).then (members) ->
                                    if members.length > 0 and _.findWhere(members, {user:User.data.id, group: 'instructor'})
                                        course.isInstructor = true
                                    else
                                        course.isInstructor = false
                                    defer.resolve(course.isInstructor)
                return defer.promise

        return new Course(Restangular, $q)
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
