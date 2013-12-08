define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    # ##Syllabus service
    angular.module('djangoApp.services').factory 'Syllabus', ($q, $rootScope, Restangular) ->
        class Syllabus extends ServiceBase
            model: 'syllabuses'
        return new Syllabus(Restangular, $q, $rootScope)
