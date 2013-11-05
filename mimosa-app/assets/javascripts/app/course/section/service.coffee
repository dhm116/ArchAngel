define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'CourseSection', ($q, Course, Restangular) ->
        class CourseSection
            sections: []

            get: (ids) =>
                d = $q.defer()

                if typeof ids is 'string'
                    ids = [ids]

                unless _.every(ids, (x) => _.findWhere(@sections, {id: x}))
                    Restangular.all().then (courses) =>
                        d.resolve(@__getCourse(id))
                else
                    d.resolve(@__getCourse(id))
                return d.promise
        return new CourseSection()
