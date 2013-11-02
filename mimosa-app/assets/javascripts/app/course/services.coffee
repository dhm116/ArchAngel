define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'Course', ($http, $rootScope, $cookieStore, Restangular) ->
        class Course
            courses: []

            constructor: ->
                @all()

            all: () =>
                Restangular.all('courses').getList().then (items) =>
                    @courses = items
                    console.log items
            get: (id) =>
                return _.findWhere @courses, {id: id}
        return new Course()
