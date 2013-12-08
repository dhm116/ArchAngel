define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    # ##Team service
    angular.module('djangoApp.services').factory 'Team', ($q, $rootScope, Restangular) ->
        class Team extends ServiceBase
            model: 'teams'
        return new Team(Restangular, $q, $rootScope)
    # ##Team members service
    angular.module('djangoApp.services').factory 'TeamMember', ($q, $rootScope, Restangular) ->
        class TeamMember extends ServiceBase
            model: 'teammembers'
        return new TeamMember(Restangular, $q, $rootScope)
