define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'User', (Restangular,$sessionStorage) ->
        class User
            token: ''
            authenticated: false
            data: {}

            constructor: () ->
                if $sessionStorage.user
                    console.log "Loading user from local storage"
                    _.extend(@, $sessionStorage.user)
                    @__attachToken()

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

                        $sessionStorage.user = @
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
                    delete $sessionStorage.user
                    # Remove token from Restangular.setDefaultHeaders
                else
                    cb()
                return

            __attachToken: () =>

        return new User()
