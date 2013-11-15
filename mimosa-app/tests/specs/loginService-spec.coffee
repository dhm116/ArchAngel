#*******
# Testing login services as defined in app/login/services.coffee
#
#  C.Wolf, 11/11/13
#
#
# define a requirejs module: dependencies - these are all of the dependencies needed for the djangoApp module.
#  - note - that this list may require updating if additional dependencies are added to the application
#  - note - to add dependencies, updates to test-main are also required
#
#  - note - these tests are designed intentionally to request data from the back-end django server and doing so 
#           is at risk of server availability.  An alternative is to use the angular-mocks library and fake responses
#*******
#
#  Login Services consist of the expected 'Login' and 'Logout' functionality.  
#
#  The expected service API is as follows:
#
#  login: User.login(username, password, callback(result))
#  logout: User.logout(callback())
#
#    where in each case, the callback() is user defined and optional.
#
#

define ['app/app', 'app/login/services', 'angular', 'angular-route', 'restangular'
        'underscore', 'ngStorage', 'loading-bar', 'markdown'], 
(app, svc, angular) ->
    describe 'Login Services unit testing:', ->     
        user = undefined

        #get ahold of an instance of the login 'User' service
        beforeEach ->
            $injector = angular.injector(['djangoApp'])
            user = $injector.get('User')
            
        
        it 'the User service should be defined', ->
            expect(user).toBeDefined()
            
        it 'login() should be defined', ->
            expect(user.login).toBeDefined()

        console.log 'test invalid login'
        it 'if the service is defined, a user tries to login with an invalid username/password (baduser/badpassword) and it should fail', ->
            username = { username: 'baduser', password: 'badpassword'}
            retval = false
            login_result = undefined
            runs ->
                user.login(username, (result)->
                    retval = true
                    login_result = result
                    )
            waitsFor ->
                retval
            , "login() should have returned", 5000
            runs ->
                expect(login_result).toBeDefined()
                expect(login_result).toBe(false)

        #
        # The following login tests require asynchronous support.  The first 'runs' command calls the login function 
        #   which results in an asynchronous server query.  If the query returns, the callback function
        #   is called, setting retval to true and cancelling the waitsFor timeout that follows.  Finally,
        #   the second 'runs' function is called and expectations are evaluated.
        #

        console.log 'test valid Login'
        it 'then a user tries to login with a valid username/password (admin/admin)', ->
            username = { username: 'admin', password: 'admin'}
            retval = false
            login_result = undefined
            runs ->
                user.login(username, (result)->
                    retval = true
                    login_result = result
                    )
            waitsFor ->
                retval
            , "login() call should have returned", 5000
            runs ->
                expect(user.authenticated).toBe(true)
                expect(user.token).toMatch('^[a-zA-Z0-9]+$')
                expect(login_result).toBeDefined()
                expect(login_result).toBe(true)


        it 'to logout, logout() should be defined', ->
            expect(user.logout).toBeDefined()

        console.log 'test Logout'
        it 'then the logged in user logs out', ->
            retval = false
            logout_result = undefined
            runs ->
                user.logout(()->
                    retval = true
                    )
            waitsFor ->
                retval
            , "logout() call should have returned", 5000
            runs ->
                expect(user.authenticated).toBe(false)
                expect(user.token).toMatch('')
                expect(user.data).toEqual({})
