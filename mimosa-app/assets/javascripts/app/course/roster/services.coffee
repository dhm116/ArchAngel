define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    # ##Roster service
    # The course roster determines which users belong to which
    # sections of a course, as well as what their role in the
    # course is.
    angular.module('djangoApp.services').factory 'CourseRoster', ($q, $rootScope, Restangular) ->
        class CourseRoster extends ServiceBase
            model: 'courserosters'

            students: (ids) =>
                defer = @$q.defer()
                @all(ids).then (students) =>
                    defer.resolve(_.filter(students, {group: 'student'}))
                return defer.promise

        return new CourseRoster(Restangular, $q, $rootScope)
