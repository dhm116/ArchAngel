define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'User', ($http, $rootScope, $cookieStore, BASE_URL) ->
        class User
            username: ''
            user_id: null
            token: ''
            authenticated: false

            login: (username, password, cb) =>
                if username.hasOwnProperty('password')
                    cb = password
                    password = username.password
                    username = username.username

                $http.post(
                    "#{BASE_URL}/api-token-auth/",
                    {username: username, password: password}
                ).then (response) =>
                    if response.data
                        @username = username
                        @token = response.data.token
                        @user_id = response.data.user_id
                        @authenticated = true
                        console.log response.data
                .catch =>
                    console.log "Invalid username/password"
                .finally =>
                    cb(@authenticated)

                return
            logout: (cb) =>
                if @authenticated
                    @name = null
                    @token = null
                    @authenticated = false
                    @user_id = null

                    $http.post("#{BASE_URL}/logout").then =>
                        cb()
                else
                    cb()
                return
        return new User()
