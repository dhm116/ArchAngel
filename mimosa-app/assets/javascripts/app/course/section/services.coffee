define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'CourseSection', ($q, Course, Restangular) ->
        class CourseSection
            sections: []

            get: (ids) =>
                d = $q.defer()

                if typeof ids is 'string'
                    ids = [ids]

                unless @sections.length
                    console.log "Loading course sections"
                    Restangular.all('coursesections').getList().then (sections) =>
                        @sections = sections
                        d.resolve(@__getSection(ids))
                else
                    d.resolve(@__getSection(ids))
                return d.promise

            __getSection: (ids) =>
                return _.filter @sections, (section) =>
                    _.contains(ids, section.id)


        return new CourseSection()