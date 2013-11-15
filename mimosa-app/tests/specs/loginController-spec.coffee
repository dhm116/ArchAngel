#
# Testing login controller as defined in app/login/controllers.coffee
#
#
# define a requirejs module: dependencies - these are all of the dependencies needed for the djangoApp module.
#  - note - that this list may require updating if additional dependencies are added to the application
#  - note - to add dependencies, updates to test-main are also required
#
#  - note - these tests use angular mocks to allow mocking of the controller and giving it an independent scope
#
#  the login controller scope contains the following properties:
#    $storage,  login (method), user
#

define ['app/app', 'app/login/controllers', 'app/login/services', 'angular', 'angular-mocks', 'angular-route', 'restangular'
        'underscore', 'ngStorage', 'loading-bar', 'markdown'], 
(app, ctrl, svc, angular) ->


    describe 'Login Controllers unit testing:', ->
        # Mock the djangoApp module
        beforeEach(module('djangoApp'))
        beforeEach(module('djangoApp.services'))
        
        describe 'LoginController scope properties', ->
            scope = undefined
            $httpBackend = undefined
            service = undefined
            

            # Create an instance of the controller with its own scope
            beforeEach(inject(($controller, $rootScope, _$httpBackend_, User)->
                service = User
                $httpBackend = _$httpBackend_
                
                scope = $rootScope.$new()
                
                $controller('LoginController', { $scope: scope, User: service })
                ))

            afterEach ->
                $httpBackend.verifyNoOutstandingExpectation()
                $httpBackend.verifyNoOutstandingRequest()


            console.log 'controller test'

            it 'should have scope.$storage.user defined', ->
                expect(scope.$storage.user).toBeDefined()

            it 'should have scope.login defined', ->
                expect(scope.login).toBeDefined()

            it 'should have scope.user undefined as it needs to be set externally', ->
                expect(scope.user).not.toBeDefined()

            it 'should have scope.user defined as username: testuser, password: password', ->
                scope.user = { username: 'testuser', password: 'password'}
                console.log scope
                expect(scope.user).toBeDefined()
                expect(scope.user.username).toBe('testuser')
                expect(scope.user.password).toBe('password')


            # need to setup a test that mocks the server response with test configured data for the login method.
            #  this requires mocking the login service and pre-configuring responses.


            it 'should allow user to login', ->
                scope.user = { username: 'cxw970', password: 'password'}
                # Create a mocked response to the expected login request
                $httpBackend.expect('POST', 'http://django-archangel.rhcloud.com/api-token-auth/?format=json').respond(200, {"token": "1f43d87c56019f8d8eca104b0de32c745efcfe5b", "user": {"username": "cxw970", "first_name": "Christopher", "last_name": "Wolf", "is_active": true, "email": "cxw970@psu.edu", "is_superuser": false, "is_staff": false, "last_login": "2013-10-29T23:51:32Z", "groups": [1], "user_permissions": [19, 20, 21, 4, 5, 6, 1, 2, 3, 7, 8, 9, 64, 65, 66, 52, 53, 54, 55, 56, 57, 31, 32, 33, 37, 38, 39, 34, 35, 36, 43, 44, 45, 49, 50, 51, 28, 29, 30, 46, 47, 48, 40, 41, 42, 25, 26, 27, 10, 11, 12, 61, 62, 63, 58, 59, 60, 13, 14, 15, 16, 17, 18], "id": 4, "date_joined": "2013-10-29T23:51:32Z"}})
                scope.login()
                $httpBackend.flush()
                # Now check for expected data returned
                expect(scope.$storage.user.authenticated).toBe(true)
                expect(scope.$storage.user.token).toBe('1f43d87c56019f8d8eca104b0de32c745efcfe5b')
                expect(scope.$storage.user.data.username).toBe('cxw970')
                expect(scope.$storage.user.data.first_name).toBe('Christopher')
                expect(scope.$storage.user.data.last_name).toBe('Wolf')
                


             
