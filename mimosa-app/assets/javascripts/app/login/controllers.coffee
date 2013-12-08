define ['angular'], (angular) ->
    # ##Login controller
    return angular.module('djangoApp.controllers').controller 'LoginController', ($scope, $location, $localStorage, User) ->
        $scope.$storage = $localStorage.$default(user:User.user)

        # Enable the 'remember me' toggle switch
        $('.make-switch')['bootstrapSwitch']()

        # Scope login method to handle login form submission
        $scope.login = ->
            unless User.authenticated
                User.login($scope.user)
                    .then (result) ->
                        unless result
                            console.log 'Invalid username/password'
                        else
                            console.log 'Logged in'
                            $location.path('/')
                    .catch (error) ->
                        console.log error
            else
                console.log "#{User.username} is already logged in"
