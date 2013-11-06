define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'User', (Restangular,$localStorage) ->
        class User
            token: ''
            authenticated: false
            data: {}

            constructor: () ->
                if $localStorage.user
                    console.log "Loading user from local storage", $localStorage.user
                    _.extend(@, $localStorage.user)
                    @__attachToken()

            login: (username, password, cb) =>
                if username.hasOwnProperty('password')
                    cb = password
                    password = username.password
                    username = username.username

                Restangular.allUrl('user', 'api-token-auth')
                    .post({username:username, password:password})
                    .then (response) =>
                        console.log response
                        @token = response.token
                        @authenticated = true

                        _.extend(@data, response.user)

                        $localStorage.user = @
                        console.log "Updating local storage with user", $localStorage.user
                       # Add token to Restangular.setDefaultHeaders
                        @__attachToken()
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
                    delete $localStorage.user
                    # Remove token from Restangular.setDefaultHeaders
                    Restangular.setDefaultHeaders {}
                else
                    cb()
                return

            __attachToken: () =>
                Restangular.setDefaultHeaders {Authorization: "Token #{@token}"}

        return new User()
