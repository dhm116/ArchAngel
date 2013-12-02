define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'AssignmentSubmission', ($q, $rootScope, Restangular) ->
        class AssignmentSubmission extends ServiceBase
            model: 'assignmentsubmissions'
        return new AssignmentSubmission(Restangular, $q, $rootScope)
