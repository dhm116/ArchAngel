# Configure RequireJS by:
#
# 1) Defining an alias to the
#   AngularJS library path, which will help simplify
#   future requires for angular.
#
# 2) Adjust the base url used for all require
#   statements.
#
# 3) Configure an angular shim in case it was not
#   defined using the define() method of RequireJS
require.config
    paths:
        angular: 'vendor/angular/angular'
    baseUrl: 'javascripts'
    shim:
        'angular': {'exports':'angular'}
    priority: ['angular']

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

        # Initialize the Metronic theme handlers
        # once the application is ready to render.
        $(document).ready ->
            console.log 'Initializing metronic'
            Metronic.init()
            # FormDropzone.init()
            # FormFileUpload.init()
            return

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

            # Use the browser user-agent or the screen
            # size to determine if we should render
            # mobile-specific views.
            isMobile = mobilecheck.isMobile()

            # Grab a reference to our Amazon S3 storage
            # bucket for handling uploads
            # bucket = new AWS.S3 {params: {Bucket: 'archangel'}}

            # Just a test to verify connectivity to S3
            # bucket.listObjects (err, data) ->
            #     console.log "S3 Results: ", err, " ", data

            # Simple helper method for Restangular to
            # load all data for the provided resource
            # and add it to the local $scope.
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
            # <required> [model]:
            #       <required> template: 'name of template to load'
            #       <optional> controller: 'name of controller to load'
            #       <optional> restful: true/false
            #       <optional> nested:
            #                       -- repeated --
            #
            # The login route will end up looking like:
            #   http://<hostname>/login
            #
            # Defining "result: true" will result in
            # the following route being generated:
            #   http://<hostname>/<model name>/[action]/[id]
            #
            # Restful routes allow for the following patterns:
            #   http://<hostname>/course/view/1
            #   http://<hostname>/course/add/new
            #   http://<hostname>/course/edit/5
            #
            # as well as the following nested patterns:
            #   http://<hostname>/course/view/1/lesson/view/1
            #   http://<hostname>/course/view/1/syllabus/edit/2
            routeMap = {
                login:
                    template: 'login'
                    controller: 'LoginController'
                course:
                    restful: true
                    template: 'course'
                    # controller: 'CourseController'
                    nested:
                        section:
                            restful: true
                            template: 'course'
                            controller: 'CourseController'
                        lesson:
                            restful: true
                            template: 'lesson'
                            # controller: 'LessonController'
                            nested:
                                forum:
                                    restful: true
                                    template: 'forum'
                                assignment:
                                    restful: true
                                    template: 'assignment'
                            #        controller: 'AssignmentController'
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
                            # controller: 'SyllabusController'
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

            recursiveResourceFinder = (parent, resource) ->
                for item, options of parent
                    if item.indexOf(resource) is 0 and resource.indexOf(item) is 0
                        # console.log "Found #{resource}!", item, options
                        return {resource: item, options: options, routeName: item}
                    else if options.nested?
                        # console.log "Searching for nested resource in #{item}: ",options
                        nested = recursiveResourceFinder(options.nested, resource)
                        if nested
                            nested.routeName = "#{item}-#{nested.routeName}"
                            return nested
                return null

            createRoute = ($routeProvider, route, name, data) ->
                console.log "Building routes for #{name} (#{data.namedRoute}): #{route}"
                $routeProvider.when route, {
                    template: ($routeParams) ->
                        # resource = ""
                        # locationParts = window.location.pathname.split('/')
                        # if locationParts.length > 3
                        #     resource = locationParts[-3..-3] + ""
                        #     $routeParams.parentResource = locationParts[1..1] + ""
                        # else
                        #     resource = locationParts[-1..-1] + ""

                        # $routeParams.resource = resource
                        $routeParams.resources = []
                        if _.keys($routeParams).length > 1
                            for key,val of $routeParams when key isnt 'resources'
                                [resource, type] = key.split('_')
                                existing = _.findWhere($routeParams.resources,{resource:resource})
                                unless existing
                                    existing = {resource:resource}
                                    $routeParams.resources.push existing
                                existing[type] = val
                                # delete $routeParams[key]
                        else
                            locationParts = window.location.pathname.split('/')
                            $routeParams.resources.push {resource: locationParts[-1..-1]+""}

                        if $routeParams.resources.length > 0
                            param = _.last($routeParams.resources)
                            resource = param.resource
                            options = routeMap[resource] or recursiveResourceFinder(routeMap, resource)?.options
                            # console.log "Options for #{resource}", options
                            return getTemplate(unless options.restful then options.template else "#{param.action}-#{options.template}")
                        return
                    controller: if data.controller then data.controller else "#{name[0].toUpperCase()}#{name[1..-1]}Controller"
                    name: data.namedRoute
                }

            recursiveRouteBuilder = ($routeProvider, routes, baseURL, parentResource) ->
                for name, data of routes
                    route = baseURL + "/#{name}"
                    if data.restful
                        route += "/:#{name}_action/:#{name}_id"
                    data.namedRoute = (parentResource or '') + name
                    createRoute($routeProvider, route, name, data)

                    if data.nested?
                        recursiveRouteBuilder($routeProvider, data.nested, route, data.namedRoute + "-")

            app.config ($routeProvider, $locationProvider) ->

                recursiveRouteBuilder($routeProvider, routeMap, "")

                $routeProvider.otherwise {
                        template: getTemplate('main-screen') #templates['main-screen']
                        controller: 'ArchangelController'
                }
                $locationProvider.html5Mode(true)

            angular.module('djangoApp.controllers') #, ['restangular', 'djangoApp.services'])
                .controller 'NavbarController', ($scope,$location,$localStorage,Restangular, BASE_URL, User, Course) ->
                    $scope.$storage = $localStorage.$default {useLocalData: true}
                    $scope.isMobile = isMobile
                    $scope.user = User

                    $scope.$on 'logout', =>
                        $location.path('/login')

                    # Course.all().then (courses) ->
                    #     $scope.courses = courses

                    # $scope.useLocalData = $localStorage.useLocalData
                    $scope.updateDataURL = () ->
                        $scope.$storage.useLocalData = !$scope.$storage.useLocalData

                        url = 'http://localhost:8000'
                        unless $scope.$storage.useLocalData
                            url = 'http://django-archangel.rhcloud.com'

                        Restangular.setBaseUrl "#{url}/"

                        $location.path('/')

                .controller 'SidebarController', ($scope, $location, $routeParams, Restangular, growl, User, Course, Lesson, Forum) ->
                    $scope.isMobile = isMobile
                    $scope.user = User
                    $scope.moment = moment

                    $scope.$on 'login', =>
                        Course.all().then (courses) ->
                            $scope.courses = courses

                    $scope.$on 'logout', =>
                        $scope.courses = []
                        $scope.courseParams = null
                        $scope.lessonParams = null
                        $scope.forumParams = null
                        $scope.routeParams = null

                    $scope.$on 'forums-updated', () ->
                        # console.log 'Forums were updated: ', arguments
                        Course.all(null, true).then (courses) ->
                            $scope.courses = courses

                            Forum.all().then (forums) ->
                                if forums?.length > 0
                                    $scope.forums = _.indexBy(forums, 'id')

                                    # for course in courses

                    # params = _.last($routeParams.resources)

                    $scope.$on 'error', (event, err) ->
                        # console.log err
                        {service, error} = err
                        for field, msg of error.data
                            growl.addErrorMessage("#{msg.join()} - '#{field}'")

                    updateRouteParams = () =>
                        $scope.courseParams = _.findWhere($routeParams.resources, {resource:'course'})
                        $scope.lessonParams = _.findWhere($routeParams.resources, {resource:'lesson'})
                        $scope.forumParams = _.findWhere($routeParams.resources, {resource:'forum'})
                        $scope.teamParams = _.findWhere($routeParams.resources, {resource:'team'})
                        $scope.gradeParams = _.findWhere($routeParams.resources, {resource:'grade'})
                        $scope.routeParams = $routeParams


                    if User.authenticated
                        Course.all().then (courses) ->
                            $scope.courses = courses

                            lessonIds = []
                            lessonIds.push course.lessons for course in $scope.courses

                            # This flattens the array to keep it as a
                            # single dimension
                            lessonIds = _.flatten(lessonIds)

                            forumIds = []
                            forumIds.push course.forums for course in $scope.courses

                            # This flattens the array to keep it as a
                            # single dimension
                            forumIds = _.flatten(forumIds)

                            Lesson.all(lessonIds).then (lessons) ->
                                $scope.lessons = _.indexBy(lessons, 'id')
                            Forum.all(forumIds).then (forums) ->
                                $scope.forums = _.indexBy(forums, 'id')

                    $scope.$on '$routeChangeSuccess', () =>
                        # console.log "route changed", arguments
                        updateRouteParams()

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
                        #     for course in $scope.courses
                        #         Course.upcomingAssignments(course.id).then (upcoming) =>
                        #             course.upcoming = upcoming
                        # $scope.moment = moment
                        # unless isMobile
                        #     getAllData(Restangular, $scope, 'users')


            angular.bootstrap document, ['djangoApp']
