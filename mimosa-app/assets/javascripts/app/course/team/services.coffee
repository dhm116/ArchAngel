define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Team', ($q, $rootScope, Restangular) ->
        class Team extends ServiceBase
            model: 'teams'
        return new Team(Restangular, $q, $rootScope)

    angular.module('djangoApp.services').factory 'TeamMember', ($q, $rootScope, Restangular) ->
        class TeamMember extends ServiceBase
            model: 'teammembers'
        return new TeamMember(Restangular, $q, $rootScope)
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
