define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    # ##Course section service
    angular.module('djangoApp.services').factory 'CourseSection', ($q, $rootScope, Restangular) ->
        class CourseSection extends ServiceBase
            model: 'coursesections'
        return new CourseSection(Restangular, $q, $rootScope)
