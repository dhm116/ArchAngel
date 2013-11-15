define ['angular', 'app/app', 'app/login/services', 'angular-route', 'restangular'
        'underscore', 'ngStorage', 'loading-bar', 'markdown'],
(angular, app, Login) ->
    describe 'Login Services', ->
        user = undefined

        beforeEach( ->
            $injector = angular.injector(['djangoApp'])
            user = $injector.get('User')
            )

        it 'the User service should be defined', ->
            expect(user).toBeDefined()



        it 'the login should be defined', ->
            expect(user.login).toBeDefined()


        it 'a user tries to login with an invalid username/password', ->
            username = { username: 'baduser', password: 'badpassword'}
            retval = false
            login_result = undefined
            runs ->
                user.login(username)
                    .then (result)->
                        retval = true
                        login_result = result
                        console.log result
                    .catch (result) ->
                        retval = true
                        login_result = false
            waitsFor( ->
                retval
            , "login should have returned", 5000)

            runs ->
                expect(login_result).toBeDefined()
                expect(login_result).toBe(false)


        it 'then tries to login with a valid username/password', ->
            username = { username: 'admin', password: 'admin'}
            retval = false
            login_result = undefined
            runs ->
                user.login(username)
                    .then (result)->
                        retval = true
                        login_result = result
                    .catch (result) ->
                        retval = true
                        login_result = false
            waitsFor( ->
                retval
            , "login should have returned", 5000)

            runs ->
                expect(login_result).toBeDefined()
                expect(login_result).toBe(true)
