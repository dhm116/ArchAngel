define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'Course', ($q, Restangular) ->
        class Course
            courses: []
            d: null

            constructor: ->

            all: () =>
                unless @d
                    @d = $q.defer()

                    unless @courses.length
                        Restangular.all('courses').getList().then (items) =>
                            @courses = items
                            # console.log "In async course service", @courses
                            console.log 'Getting list of courses'
                            @d.resolve(@courses)
                    else
                        console.log 'Using cached course list'
                        console.log @courses
                        @d.resolve(@courses)

                return @d.promise

            get: (id) =>
                d = $q.defer()

                unless @courses.length
                    @all().then (courses) =>
                        d.resolve(@__getCourse(id))
                else
                    d.resolve(@__getCourse(id))
                return d.promise

            __getCourse: (id) =>
                return _.findWhere @courses, {id: id}

        return new Course()
