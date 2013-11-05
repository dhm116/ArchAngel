define ['angular'], (angular) ->
    return angular.module('djangoApp.controllers').controller 'LoginController', ($scope, $http, $sessionStorage, User, Restangular) ->
        $scope.$storage = $sessionStorage.$default(user:User)
        $scope.login = ->
            # $http.post(
            #     'http://django-archangel.rhcloud.com/api-token-auth/',
            #     $scope.user
            # ).then (response) ->
            #     console.log response
            # console.log User.authenticated
            if($scope.user)
                if $sessionStorage.user.token == '' #is anyone logged in
                    unless User.loggedIn($scope.user.username) #is specific user logged in
                    
                     
                        User.login $scope.user, (result) ->
                            unless result
                                console.log 'Invalid username/password'
                            else
                                $sessionStorage.user = User
                                console.log 'Logged in'
                            Restangular.one('courses', $routeParams.courseId).get().then (course) ->
                                $scope.course = course
                    # console.log User
                
                    
                    else
                        User.setUser($sessionStorage.user)
                        console.log "#{User.username} was previously logged in #{User.token}"

                else
                    User.setUser($sessionStorage.user)
                    console.log "#{User.username} is already logged in"
            else
                console.log "$scope.user undefined"

        $scope.logout = ->
            console.log "attempt logout"
            unless $sessionStorage.user.token == ''
                User.logout (result) ->
                    unless result #user logged out
                        $sessionStorage.user = User
                    else
                        console.log "logout failed"
            else                
                console.log "No one is logged in"
