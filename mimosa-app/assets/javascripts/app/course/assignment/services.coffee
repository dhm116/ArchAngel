define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'Assignment', ($q, Course, Restangular) ->
        class Assignment
            assignments: []

            get: (ids) =>
                d = $q.defer()

                unless Array.isArray(ids)
                    ids = [ids]

                unless @assignments.length
                    console.log "Loading course assignments"
                    Restangular.all('assignments').getList().then (assignments) =>
                        @assignments = assignments
                        d.resolve(@__getAssignment(ids))
                else
                    d.resolve(@__getAssignment(ids))
                return d.promise

            __getAssignment: (ids) =>
                unless _.every(ids, _.isNumber)
                    return ids

                return _.filter @assignments, (assignment) =>
                    _.contains(ids, assignment.id)


        return new Assignment()
