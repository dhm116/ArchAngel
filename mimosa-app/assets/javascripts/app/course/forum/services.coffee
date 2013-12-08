define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    # ##Forum service
    angular.module('djangoApp.services').factory 'Forum', ($q, $rootScope, Restangular) ->
        class Forum extends ServiceBase
            model: 'forums'
        return new Forum(Restangular, $q, $rootScope)

    # ##Forum post service
    angular.module('djangoApp.services').factory 'ForumPost', ($q, $rootScope, Restangular) ->
        class ForumPost extends ServiceBase
            model: 'forumposts'
        return new ForumPost(Restangular, $q, $rootScope)
