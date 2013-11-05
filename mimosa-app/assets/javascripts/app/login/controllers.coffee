define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'LoginController', ($scope, $location, $localStorage, User) ->
        $scope.$storage = $localStorage.$default(user:User)

        $scope.login = ->
            unless User.authenticated
                User.login $scope.user, (result) ->
                    unless result
                        console.log 'Invalid username/password'
                    else
                        console.log 'Logged in'
                        $location.path('/')
            else
                console.log "#{User.username} is already logged in"
