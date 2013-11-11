define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'CourseRoster', ($q, Restangular) ->
        class CourseRoster extends ServiceBase
            model: 'courserosters'
        return new CourseRoster(Restangular, $q)
        # class CourseRoster
        #     rosters: []

        #     get: (ids) =>
        #         d = $q.defer()

        #         if typeof ids is 'string'
        #             ids = [ids]

        #         unless @rosters.length
        #             console.log "Loading course rosters"
        #             Restangular.all('courserosters').getList().then (rosters) =>
        #                 @rosters = rosters
        #                 d.resolve(@__getRoster(ids))
        #         else
        #             d.resolve(@__getRoster(ids))
        #         return d.promise

        #     __getRoster: (ids) =>
        #         return _.filter @rosters, (roster) =>
        #             _.contains(ids, roster.id)


        # return new CourseRoster()
