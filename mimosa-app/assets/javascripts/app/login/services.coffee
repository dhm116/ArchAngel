define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'User', ($http, $rootScope, $cookieStore, Restangular) -> #BASE_URL) ->
        class User
            token: ''
            authenticated: false
            data: {}

            login: (username, password, cb) =>
                if username.hasOwnProperty('password')
                    cb = password
                    password = username.password
                    username = username.username

                Restangular.allUrl('user', 'api-token-auth')
                    .post({username:username, password:password})
                    .then (response) =>
                        @token = response.token
                        @authenticated = true

                        _.extend(@data, response.user)

                        # Add token to Restangular.setDefaultHeaders
                    .catch =>
                        console.log "Invalid username/password"
                    .finally =>
                        cb(@authenticated)

                return
            logout: (cb) =>
                if @authenticated
                    @data = {}
                    @token = null
                    @authenticated = false

                    # Remove token from Restangular.setDefaultHeaders
                else
                    cb()
                return
        return new User()
