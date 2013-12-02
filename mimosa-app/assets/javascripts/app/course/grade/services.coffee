define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'GradedAssignmentSubmission', ($q, $rootScope, Restangular) ->
        class GradedAssignmentSubmission extends ServiceBase
            model: 'gradedassignmentsubmissions'
        return new GradedAssignmentSubmission(Restangular, $q, $rootScope)
