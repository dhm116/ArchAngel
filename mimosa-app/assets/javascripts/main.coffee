# ##RequireJS configuration
# Configure RequireJS by:
#
# 1. Defining an alias to the
#   AngularJS library path, which will help simplify
#   future requires for angular.
# 2. Adjust the base url used for all require
#   statements.
# 3. Configure an angular shim in case it was not
#   defined using the define() method of RequireJS
require.config
    paths:
        angular: 'vendor/angular/angular'
    baseUrl: 'javascripts'
    shim:
        'angular': {'exports':'angular'}
    priority: ['angular']

# ##Load dependencies
# This is our main application entry-point, which
# defines our base dependencies, a url argument
# that will be appended to every library load request
# that helps to prevent browser caching and a jQuery
# alias to simplify any future references.
require
    urlArgs: "b=#{(new Date()).getTime()}"
    paths:
        jquery: 'vendor/jquery/jquery.min'
    ,

    # These are our core dependencies - our application
    # will delay being loaded until all of these have
    # been retrieved and are ready.
    [
        'angular'
        'templates'
        'app/mobile-check'
        'app/app'
        'app/s3'
    ]

    # Here we receive our defined base dependencies
    # to use in our application.
    ,(angular, templates, mobilecheck, app) ->
        # ## Main.coffee has been loaded
        # Initialize the Metronic theme handlers
        # once the application is ready to render.
        $(document).ready ->
            console.log 'Initializing metronic'
            # Metronic is our add-on theme for
            # Twitter Bootstrap 3
            Metronic.init()
            return

        # ##Load local angular modules
        # Here we load our application's angular
        # services and controllers. We do this
        # after angular has been loaded to avoid
        # any race conditions since RequireJS
        # does not load in any guaranteed order.
        #
        # Note that we don't handle these libraries
        # in the callback because they already have
        # registered themselves with angular.
        require [
            'app/login/services'
            'app/login/controllers'
            'app/course/services'
            'app/course/controllers'
            'app/course/roster/services'
            'app/course/section/services'
            'app/course/section/controllers'
            'app/course/syllabus/controllers'
            'app/course/syllabus/services'
            'app/course/lesson/services'
            'app/course/lesson/controllers'
            'app/course/lesson/assignment/services'
            'app/course/lesson/assignment/controllers'
            'app/course/lesson/assignment/submission/services'
            'app/course/lesson/assignment/submission/controllers'
            'app/course/grade/services'
            'app/course/grade/controllers'
            'app/course/team/services'
            'app/course/team/controllers'
            'app/course/forum/services'
            'app/course/forum/controllers'
        ], ->
            # ##All dependencies have been loaded
            # Use the browser user-agent or the screen
            # size to determine if we should render
            # mobile-specific views.
            isMobile = mobilecheck.isMobile()

            # Simple helper method for Restangular to
            # load all data for the provided resource
            # and add it to the local `$scope` .
            getAllData = (service, $scope, resource) ->
                service.all(resource).getList().then (items) ->
                    $scope[resource] = items

            # Simple helper method for selectively
            # returning the mobile-specific template
            # if needed and one exists.
            getTemplate = (name) ->
                template = templates[name]

                # We check to see if the compiled Jade
                # templates library contains a mobile
                # version of the requested template name.
                if isMobile and templates.hasOwnProperty("#{name}_mobile")
                    template = templates["#{name}_mobile"]

                return template

            # This map of URL routes helps the angular
            # router determine which controllers and
            # templates to load for a given URL.
            #
            # The pattern is:
            # - test `model` (**_required_**):
            #   - `template` (**_required_**): the name of the template to load
            #   - `controller` (*optional*): the name of the controller to load. If
            #     undefined, a controller named ModelController will be used (
            #     e.g. `YogurtController` if the model was defined as `yogurt`)
            #   - `restful` (*optional*): true/false
            #   - `nested` (*optional*):
            #     - -- repeated --
            #
            # The login route will end up looking like:
            #   `http://my.site.com/login`
            #
            # Defining `restful: true` will result in
            # the following route being generated:
            #   `http://my.site.com/model_name/[action]/[id]`
            #
            # Restful routes allow for the following patterns:
            #   `http://my.site.com/course/view/1`
            #   `http://my.site.com/course/add/new`
            #   `http://my.site.com/course/edit/5`
            #
            # as well as the following nested patterns:
            #   `http://my.site.com/course/view/1/lesson/view/1`
            #   `http://my.site.com/course/view/1/syllabus/edit/2`
            routeMap = {
                login:
                    template: 'login'
                    controller: 'LoginController'
                course:
                    restful: true
                    template: 'course'
                    nested:
                        section:
                            restful: true
                            template: 'course'
                            controller: 'CourseController'
                        lesson:
                            restful: true
                            template: 'lesson'
                            nested:
                                forum:
                                    restful: true
                                    template: 'forum'
                                assignment:
                                    restful: true
                                    template: 'assignment'
                                    nested:
                                        submission:
                                            restful: true
                                            template: 'submission'
                                            nested:
                                                grade:
                                                    restful: true
                                                    template: 'grade'
                                                    controller: 'GradedAssignmentSubmissionController'
                        syllabus:
                            restful: true
                            template: 'syllabus'
                        forum:
                            restful: true
                            template: 'forum'
                        team:
                            restful: true
                            template: 'team'
                grade:
                    restful: true
                    template: 'grade'
                    controller: 'GradedAssignmentSubmissionController'
                team:
                    restful: true
                    template: 'team'
                    controller: 'TeamController'
            }

            # ###Recursive Resource Finder
            # Simple helper method to assist in traversing the
            # URL to locate the `routeMap` configuration of the
            # target resource.
            #
            # Returns an object containing the **name** of the
            # resource located, the **configuration** defined
            # and a **named route** for use with the angular
            # named route module.
            #
            # First, we loop through each resource defined in the parent
            # configuration node. Keys (`item`) will be the name of the
            # resource in the configuration. Values (`options`) will be the
            # configuration defined for that resource. We check if this item
            # matches our target resource and return it if it matches. If not,
            # we'll check if this item has any nested resources defined.
            #
            # Nested resources will recursively call `recurseResourceFinder` (
            # hence the name) until the route configuration has no more nested
            # resources defined.
            #
            # If the result is a nested route, we add the parent resource to the
            # beginning of the resulting named route to keep everything in context
            # later on.
            #
            # If no results are found, we return null
            recursiveResourceFinder = (parent, resource) ->
                for item, options of parent
                    if item.indexOf(resource) is 0 and resource.indexOf(item) is 0
                        return {resource: item, options: options, routeName: item}
                    else if options.nested?
                        nested = recursiveResourceFinder(options.nested, resource)
                        if nested
                            nested.routeName = "#{item}-#{nested.routeName}"
                            return nested
                return null

            # ###Create Route
            # Simple helper method for registering and handling routes defined
            # in the routeMap configuration with the angular routing service
            #
            # * `$routeProvider` is a reference to the angular route service
            # * `route` is the URL to listen for (e.g. /something/:id)
            # * `name` is the name of the `routeMap` resource associated with
            #   this route
            # * `data` is the configuration data
            createRoute = ($routeProvider, route, name, data) ->
                console.log "Building routes for #{name} (#{data.namedRoute}): #{route}"
                $routeProvider.when route, {
                    template: ($routeParams) ->
                        $routeParams.resources = []
                        if _.keys($routeParams).length > 1
                            for key,val of $routeParams when key isnt 'resources'
                                [resource, type] = key.split('_')
                                existing = _.findWhere($routeParams.resources,{resource:resource})
                                unless existing
                                    existing = {resource:resource}
                                    $routeParams.resources.push existing
                                existing[type] = val
                        else
                            locationParts = window.location.pathname.split('/')
                            $routeParams.resources.push {resource: locationParts[-1..-1]+""}

                        if $routeParams.resources.length > 0
                            param = _.last($routeParams.resources)
                            resource = param.resource
                            options = routeMap[resource] or recursiveResourceFinder(routeMap, resource)?.options
                            return getTemplate(unless options.restful then options.template else "#{param.action}-#{options.template}")
                        return
                    controller: if data.controller then data.controller else "#{name[0].toUpperCase()}#{name[1..-1]}Controller"
                    name: data.namedRoute
                }

            # ###Recursive Route Builder
            # This helper method  takes the main `routeMap` configuration
            # and recursively constructs the URL's for any nested resources
            # defined. This method will call `createRoute` for each route
            # constructed.
            recursiveRouteBuilder = ($routeProvider, routes, baseURL, parentResource) ->
                for name, data of routes
                    route = baseURL + "/#{name}"
                    if data.restful
                        route += "/:#{name}_action/:#{name}_id"
                    data.namedRoute = (parentResource or '') + name
                    createRoute($routeProvider, route, name, data)

                    if data.nested?
                        recursiveRouteBuilder($routeProvider, data.nested, route, data.namedRoute + "-")

            # ##Main Application Configuration
            # Here we define our application-specific configuration parameters
            # for our main Angular module, `djangoApp`.
            #
            # We use this configuration method to construct and register our
            # routes using the `recursiveRouteBuilder` method. We will also
            # register our default route handler using `$routeProvider.otherwise`
            # to avoid `404 Page Missing` errors.
            #
            # **_Note_** setting `$locationProvider.html5Mode(true)` will allow
            # the angular routing module to intercept URL's that look like
            # `http://my.site.com/some/page/item/id` instead of
            # `http://my.site.com/some#page/item/id`
            app.config ($routeProvider, $locationProvider) ->
                recursiveRouteBuilder($routeProvider, routeMap, "")

                $routeProvider.otherwise {
                        template: getTemplate('main-screen')
                        controller: 'ArchangelController'
                }
                $locationProvider.html5Mode(true)

            # ##Custom Directives
            # This `bsHolder` angular directive is a workaround for
            # an incompatability between angular and the holder.js
            # image placeholder library.
            #
            # To use, simply define `bs-holder` on any element
            angular.module('djangoApp').directive 'bsHolder', () ->
                return {
                    link: (scope, element, attrs) ->
                        Holder.run {images: element.get(0), nocss:true}
                }

            # ##Local Angular Controllers
            angular.module('djangoApp.controllers')
                # ###Top Navbar Controller
                # This is just a simple controller for the top navbar on
                # the site. Most of the parameters and helper methods
                # are remnants of the site using Foundation and Ratchet
                # for the UI.
                .controller 'NavbarController', ($scope,$location,$localStorage,Restangular, BASE_URL, User, Course) ->
                    $scope.$storage = $localStorage.$default {useLocalData: true}
                    $scope.isMobile = isMobile
                    $scope.user = User

                    $scope.$on 'logout', =>
                        $location.path('/login')

                    $scope.updateDataURL = () ->
                        $scope.$storage.useLocalData = !$scope.$storage.useLocalData

                        url = 'http://localhost:8000'
                        unless $scope.$storage.useLocalData
                            url = 'http://django-archangel.rhcloud.com'

                        Restangular.setBaseUrl "#{url}/"

                        $location.path('/')

                # ###Sidebar Controller
                # This sidebar controller helps keep the sidebar up-to-date
                # with model changes that affect any course links being
                # displayed.
                .controller 'SidebarController', ($scope, $location, $routeParams, Restangular, growl, User, Course, Lesson, Forum) ->
                    $scope.isMobile = isMobile
                    $scope.user = User
                    $scope.moment = moment

                    # When the user logs in, lets make sure to pull the
                    # latest list of courses for them. Forcing an update
                    # with `true` in the call will help prevent caching
                    # issues if a different user had been logged in
                    # previously.
                    $scope.$on 'login', =>
                        Course.all(null, true).then (courses) ->
                            $scope.courses = courses

                    # When the user logs out, make sure we clear out all
                    # `$scope` data for the sidebar so nothing is left
                    # over for the next login.
                    $scope.$on 'logout', =>
                        $scope.courses = []
                        $scope.courseParams = null
                        $scope.lessonParams = null
                        $scope.forumParams = null
                        $scope.routeParams = null

                    # Because we're indexing the forums by their ID to
                    # help display them easily for each course, we need
                    # to listen for any model updates so that we can re-run
                    # the index and update the scope. In case there were any
                    # additions or deletions from a course, we force-update
                    # the courses as well - this also helps keep the UI in
                    # sync with the backend and funky things happen if this
                    # doesn't occur.
                    $scope.$on 'forums-updated', () ->
                        Course.all(null, true).then (courses) ->
                            $scope.courses = courses

                            Forum.all().then (forums) ->
                                if forums?.length > 0
                                    $scope.forums = _.indexBy(forums, 'id')

                    # Just like with the forums, we need to update the courses
                    # and re-index the lessons on any model updates.
                    $scope.$on 'lessons-updated', () ->
                        Course.all(null, true).then (courses) ->
                            $scope.courses = courses

                            Lesson.all().then (lessons) ->
                                if lessons?.length > 0
                                    $scope.lessons = _.indexBy(lessons, 'id')

                    # Here we hook into the global scope `error` event so that
                    # we can display them to the user. The errors produced by
                    # `Restangular` follow a schema provided by the django
                    # response, so first we check to see if the error was generated
                    # by one of our services; if not, we just display the error
                    # provided.
                    $scope.$on 'error', (event, err) ->
                        if err.hasOwnProperty('service')
                            {service, error} = err
                            for field, msg of error.data
                                growl.addErrorMessage("#{msg.join()} - '#{field}'")
                        else
                                growl.addErrorMessage(err)

                    # Same with the errors, this hooks into the global `warning`
                    # event for displaying warnings to the user.
                    $scope.$on 'warning', (event, err) ->
                        if err.hasOwnProperty('service')
                            {service, error} = err
                            for field, msg of error.data
                                growl.addWarningMessage("#{msg.join()} - '#{field}'")
                        else
                                growl.addWarningMessage(err)

                    # This method helps encapsulate loading all of the potential
                    # route parameters that the template will use to determine what
                    # page the user is on.
                    updateRouteParams = () =>
                        $scope.courseParams = _.findWhere($routeParams.resources, {resource:'course'})
                        $scope.lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})
                        $scope.forumParams = _.findWhere($routeParams.resources, {resource:'forum'})
                        $scope.teamParams = _.findWhere($routeParams.resources, {resource:'team'})
                        $scope.gradeParams = _.findWhere($routeParams.resources, {resource:'grade'})
                        $scope.routeParams = $routeParams

                    # If the user is authenticated, go ahead and load up the list
                    # of courses, lessons and forums to populate the navigation
                    # links.
                    if User.authenticated
                        Course.all().then (courses) ->
                            $scope.courses = courses

                            lessonIds = []
                            # Here we are collecting all of the lesson ids for each
                            # course being displayed.
                            lessonIds.push course.lessons for course in $scope.courses

                            # This flattens the lesson ids array to keep it as a
                            # single dimension.
                            lessonIds = _.flatten(lessonIds)

                            forumIds = []
                            # We'll do the same thing with the forums
                            forumIds.push course.forums for course in $scope.courses

                            # This flattens the array to keep it as a
                            # single dimension
                            forumIds = _.flatten(forumIds)

                            Lesson.all(lessonIds).then (lessons) ->
                                $scope.lessons = _.indexBy(lessons, 'id')
                            Forum.all(forumIds).then (forums) ->
                                $scope.forums = _.indexBy(forums, 'id')

                    # After the URL changes, make sure we reload the route
                    # parameters to keep the UI navigation up-to-date
                    $scope.$on '$routeChangeSuccess', () =>
                        updateRouteParams()

                # ###Homepage Controller
                # This controller is referenced by `views/main-screen.jade` and
                # handles redirecting users that haven't logged in yet, as well
                # as initializing any Metronic javascript libraries used on the
                # home screen.
                .controller 'ArchangelController', ($scope, $location, Restangular, User, Course) ->
                    $scope.isMobile = isMobile
                    $scope.user = User

                    unless User.authenticated
                        $location.path('/login')
                    else
                        Index.initCalendar()
                        Tasks.initDashboardWidget()
                        Course.all().then (courses) ->
                            $scope.courses = courses


            # ##Bootstrap our Angular App
            # This helps to work around the known issue of using angular along
            # with requirejs, as you would normally declare ng-app in the main
            # `html` element
            angular.bootstrap document, ['djangoApp']
