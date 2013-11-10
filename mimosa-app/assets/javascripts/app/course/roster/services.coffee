define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'CourseRoster', ($q, Course, Restangular) ->
        class CourseRoster
            rosters: []

            get: (ids) =>
                d = $q.defer()

                if typeof ids is 'string'
                    ids = [ids]

                unless @rosters.length
                    console.log "Loading course rosters"
                    Restangular.all('courserosters').getList().then (rosters) =>
                        @rosters = rosters
                        d.resolve(@__getRoster(ids))
                else
                    d.resolve(@__getRoster(ids))
                return d.promise

            __getRoster: (ids) =>
                return _.filter @rosters, (roster) =>
                    _.contains(ids, roster.id)


        return new CourseRoster()
