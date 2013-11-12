define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'AssignmentSubmission', ($q, AssignmentSubmission, Restangular) ->
        class AssignmentSubmission
            submissions: []

            get: (ids) =>
                d = $q.defer()

                if typeof ids is 'string'
                    ids = [ids]

                unless @submissions.length
                    console.log "Loading assignment submissions"
                    Restangular.all('submissions').getList().then (submissions) =>
                        @submissions = submissions
                        d.resolve(@__getSubmissions(ids))
                else
                    d.resolve(@__getSubmissions(ids))
                return d.promise

            __getSubmissions: (ids) =>
                return _.filter @submissions, (submission) =>
                    _.contains(ids, submission.id)


        return new AssignmentSubmission()
