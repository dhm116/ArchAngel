define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'User', ($q, $rootScope, Restangular,$localStorage) ->
        # ###User Service
        # This service also handles login/logout methods for the web
        # application.
        class User extends ServiceBase
            model: 'users'
            # The token will be cached for all future `Restangular`
            # requests while the user is logged in.
            token: ''
            authenticated: false
            # Store the currently logged in user's account information
            # here.
            data: {}

            # This method is triggered automatically (from within the
            # `BaseService`) whenever angular loads this service.
            __onNewInstance: (@$localStorage, params...) =>
                # If the user's data is stored on the client (so they
                # don't have to login every time), we'll load their data
                # into this service using `_.extend`.
                if @$localStorage.user
                    console.log "Loading user from local storage", @$localStorage.user
                    if @$localStorage.user?.token != null
                        _.extend(@, @$localStorage.user)
                        # Attach the token to `Restangular`.
                        @__attachToken()
                    else
                        # If, for some reason, the client had a user
                        # object defined, but no token was found, go
                        # ahead and log them out to force a new login.
                        console.log "Cached user had no data"
                        @logout()
                return

            # ####Login
            # This method is not part of the normal REST API methods
            # handled by the `BaseService`, so we'll define it here.
            login: (username, password) =>
                # Following the angular ansynchronous model, we'll return
                # a future promise that will be called once the login
                # attempt has been completed.
                defer = @$q.defer()
                if username.hasOwnProperty('password')
                    password = username.password
                    username = username.username

                Restangular.allUrl('user', 'api-token-auth')
                    .post({username:username, password:password})
                    .then (response) =>
                        @token = response.token
                        @authenticated = true
                        # We use `_.extend` to simplify loading in all of
                        # the user's data into our `data` parameter.
                        _.extend(@data, response.user)

                        @$localStorage.user = {token: @token, authenticated: @authenticated, data: @data}
                        # Add token to Restangular.setDefaultHeaders
                        @__attachToken()
                        # Complete our original promise
                        defer.resolve(@authenticated)
                        # Then, broadcase the `login` event
                        $rootScope.$broadcast 'login', @
                    .catch (response) =>
                        defer.reject(response)

                return defer.promise

            # ####Logout
            logout: () =>
                # Following the angular ansynchronous model, we'll return
                # a future promise that will be called once the login
                # attempt has been completed.
                defer = @$q.defer()
                # Reset user data, token and authenticated status.
                @data = {}
                @token = null
                @authenticated = false

                # If there is user data stored on their client, let's
                # clear it out as well.
                if @$localStorage.user
                    @$localStorage.user = {}
                    console.log "Deleting user from local storage"
                    delete @$localStorage.user

                # Remove token from `Restangular.setDefaultHeaders`
                @Restangular.setDefaultHeaders {}
                defer.resolve()

                # Broadcast the logout event.
                $rootScope.$broadcast 'logout'

                return defer.promise

            __attachToken: () =>
                @Restangular.setDefaultHeaders {Authorization: "Token #{@token}"}

        return new User(Restangular, $q, $rootScope, $localStorage)
