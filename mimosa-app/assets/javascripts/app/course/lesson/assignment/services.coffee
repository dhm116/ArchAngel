define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Assignment', ($q, $rootScope, Restangular) ->
        class Assignment extends ServiceBase
            model: 'assignments'
        return new Assignment(Restangular, $q, $rootScope)
