#*******
# Testing section services as defined in app/course/section/services.coffee
#
#  C.Wolf, 11/14/13
#
# define a requirejs module: dependencies - these are all of the dependencies needed for the djangoApp module.
#  - note - that this list may require updating if additional dependencies are added to the application
#  - note - to add dependencies, updates to test-main are also required
#
#  - note - these tests are designed intentionally to request data from the back-end django server and doing so 
#           is at risk of server availability.  An alternative is to use the angular-mocks library and fake responses
#*******
#
#  Section Services consist of TBD 
#
#  The expected service API is as follows:
#
#  TBD

define ['app/app', 'app/course/section/services', 'angular', 'angular-route', 'restangular'
        'underscore', 'ngStorage', 'loading-bar', 'markdown'], 
(app, svc, angular) ->
    describe 'SectionServices unit testing:', ->

        it 'should initially fail', ->
            expect(true).toBe(false)