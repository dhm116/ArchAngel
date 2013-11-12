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

define ['app/app', 'app/login/controllers', 'angular', 'angular-mocks', 'angular-route', 'restangular'
        'underscore', 'ngStorage', 'loading-bar', 'markdown'], 
(app, ctrl, angular) ->


    describe 'Login Controllers unit testing:', ->
        # Mock the djangoApp module
        beforeEach(module('djangoApp'))
        
        describe 'LoginController', ->
            scope = undefined

            # Create an instance of the controller with its own scope
            beforeEach(inject(($controller, $rootScope)->
                scope = $rootScope.$new()
                $controller('LoginController', { $scope: scope })
                ))

            console.log 'controller test'

            it 'should have scope.$storage.user defined', ->
                expect(scope.$storage.user).toBeDefined()

            it 'should have scope.login defined', ->
                expect(scope.login).toBeDefined()
