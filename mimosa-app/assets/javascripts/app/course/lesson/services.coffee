define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'Lesson', ($q, $rootScope, Restangular) ->
        class Lesson extends ServiceBase
            model: 'lessons'
        return new Lesson(Restangular, $q, $rootScope)
