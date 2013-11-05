define ['angular'], (angular) ->
    angular.module('djangoApp.services').factory 'User', ($http, $rootScope, $cookieStore, BASE_URL) ->
        class User
            username: ''
            firstname: ''
            lastname: ''
            user_id: undefined
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
                        @firstname = response.data.user.first_name
                        @lastname = response.data.user.last_name
                        @token = response.data.token
                        @user_id = response.data.user.id
                        @authenticated = true
                        console.log response.data
                .catch =>
                    console.log "Invalid username/password"
                .finally =>
                    cb(@authenticated)

                return

            logout: (cb) =>
                @username = ''
                @firstname = ''
                @lastname = ''
                @token = ''
                @authenticated = false
                @user_id = undefined


                $http.post("#{BASE_URL}/logout")#.then =>
                
                .catch =>
                    console.log "Server Logout Failed"
                .finally =>
                    cb(@authenticated)

                return
            
            loggedIn: (username) =>
                console.log @
                result = @authenticated and (@username == username)
                return result

            setUser: (user) =>
                @username = user.username
                @firstname = user.firstname
                @lastname = user.lastname
                @user_id = user.user_id
                @token = user.token
                @authenticated = user.authenticated
                return

        return new User()
