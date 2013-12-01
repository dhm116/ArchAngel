define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Syllabus', ($q, $rootScope, Restangular) ->
        class Syllabus extends ServiceBase
            model: 'syllabuses'
        return new Syllabus(Restangular, $q, $rootScope)
        # class Syllabus
        #     syllabus: {}

        #     get: (id) =>
        #         d = $q.defer()

        #         unless @syllabus.hasOwnProperty('id') && @syllabus.id isnt id
        #             console.log "Loading course syllabus"
        #             Restangular.one('syllabuses', id).get().then (syllabus) =>
        #                 @syllabus = syllabus
        #                 d.resolve(@syllabus)
        #         else
        #             d.resolve(@syllabus)
        #         return d.promise

        # return new Syllabus()
