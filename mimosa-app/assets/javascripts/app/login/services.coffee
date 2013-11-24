# define ['angular'], (angular) ->
#     angular.module('djangoApp.services').factory 'User', (Restangular,$localStorage) ->
define ['angular', 'app/common/base-service'], (angular, ServiceBase) ->
    angular.module('djangoApp.services').factory 'User', ($q, $rootScope, Restangular,$localStorage) ->
        class User extends ServiceBase
            model: 'users'
            token: ''
            authenticated: false
            data: {}

            __onNewInstance: (@$localStorage, params...) =>
                if @$localStorage.user
                    console.log "Loading user from local storage", @$localStorage.user
                    if @$localStorage.user?.token != null
                        _.extend(@, @$localStorage.user)
                        @__attachToken()
                    else
                        console.log "Cached user had no data"
                        @logout()
                return

            login: (username, password) =>
                defer = @$q.defer()
                if username.hasOwnProperty('password')
                    password = username.password
                    username = username.username

                Restangular.allUrl('user', 'api-token-auth')
                    .post({username:username, password:password})
                    .then (response) =>
                        # console.log response.user
                        @token = response.token
                        @authenticated = true

                        _.extend(@data, response.user)

                        @$localStorage.user = {token: @token, authenticated: @authenticated, data: @data}
                        # console.log "Updating local storage with user", $localStorage.user
                        # Add token to Restangular.setDefaultHeaders
                        @__attachToken()
                        defer.resolve(@authenticated)
                        $rootScope.$broadcast 'login', @
                    .catch (response) =>
                        # console.log "Invalid username/password"
                        defer.reject(response)

                return defer.promise

            logout: () =>
                defer = @$q.defer()
                @data = {}
                @token = null
                @authenticated = false

                if @$localStorage.user
                    console.log "Deleting user from local storage"
                    delete @$localStorage.user

                # Remove token from Restangular.setDefaultHeaders
                @Restangular.setDefaultHeaders {}
                defer.resolve()

                $rootScope.$broadcast 'logout'

                return defer.promise

            __attachToken: () =>
                @Restangular.setDefaultHeaders {Authorization: "Token #{@token}"}

        return new User(Restangular, $q, $localStorage)
        # class User
        #     token: ''
        #     authenticated: false
        #     data: {}

        #     constructor: () ->
        #         if $localStorage.user
        #             console.log "Loading user from local storage", $localStorage.user
        #             if $localStorage.user.hasOwnProperty('data')
        #                 _.extend(@, $localStorage.user)
        #                 @__attachToken()
        #             else
        #                 console.log "Cached user had no data"
        #                 @logout()

        #     login: (username, password, cb) =>
        #         if username.hasOwnProperty('password')
        #             cb = password
        #             password = username.password
        #             username = username.username

        #         Restangular.allUrl('user', 'api-token-auth')
        #             .post({username:username, password:password})
        #             .then (response) =>
        #                 console.log response.user
        #                 @token = response.token
        #                 @authenticated = true

        #                 _.extend(@data, response.user)

        #                 $localStorage.user = @
        #                 console.log "Updating local storage with user", $localStorage.user
        #                # Add token to Restangular.setDefaultHeaders
        #                 @__attachToken()
        #             .catch =>
        #                 console.log "Invalid username/password"
        #             .finally =>
        #                 cb(@authenticated)

        #         return
        #     logout: (cb) =>
        #         @data = {}
        #         @token = null
        #         @authenticated = false

        #         if $localStorage.user
        #             console.log "Deleting user from local storage"
        #             delete $localStorage.user

        #         # Remove token from Restangular.setDefaultHeaders
        #         Restangular.setDefaultHeaders {}
        #         if cb then cb()

        #         return

        #     __attachToken: () =>
        #         Restangular.setDefaultHeaders {Authorization: "Token #{@token}"}

        # return new User()
