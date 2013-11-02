define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'LoginController', ($scope, $http, User, Restangular) ->
        $scope.login = ->
            # $http.post(
            #     'http://django-archangel.rhcloud.com/api-token-auth/',
            #     $scope.user
            # ).then (response) ->
            #     console.log response
            # console.log User.authenticated
            unless User.authenticated
                User.login $scope.user, (result) ->
                    unless result
                        console.log 'Invalid username/password'
                    else
                        console.log 'Logged in'
                    Restangular.one('courses', $routeParams.courseId).get().then (course) ->
                        $scope.course = course
                    # console.log User
            else
                console.log "#{User.username} is already logged in"
