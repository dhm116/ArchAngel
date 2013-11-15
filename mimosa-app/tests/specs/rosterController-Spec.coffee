#*******
# Testing roster controller as defined in app/course/roster/controllers.coffee
#
#  C.Wolf, 11/14/13
#
#
# define a requirejs module: dependencies - these are all of the dependencies needed for the djangoApp module.
#  - note - that this list may require updating if additional dependencies are added to the application
#  - note - to add dependencies, updates to test-main are also required
#
#  - note - these tests use angular mocks to allow mocking of the controller and giving it an independent scope
#
#*******
#
#  the roster controller scope contains the following properties:
#    TBD
#

define ['app/app', 'app/course/roster/controllers', 'app/course/roster/services', 'angular', 'angular-mocks', 'angular-route', 'restangular'
        'underscore', 'ngStorage', 'loading-bar', 'markdown'], 
(app, ctrl, svc, angular) ->


    describe 'RosterControllers unit testing:', ->
       it 'should initially fail', ->
           expect(true).toBe(false)
