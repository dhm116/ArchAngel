require.config
    paths:
        angular: 'vendor/angular/angular'
    baseUrl: '/javascripts'
    shim:
        'angular': {'exports':'angular'}
    priority: ['angular']

require
    urlArgs: "b=#{(new Date()).getTime()}"
    paths:
        jquery: 'vendor/jquery/jquery'
    ,[
        'angular'
        'templates'
        'app/mobile-check'
        'app/app'
    ]
    ,(angular, templates, mobilecheck, app) ->
        #$(document).foundation()
        $(document).ready ->
            console.log 'Initializing metronic'
            Metronic.init()
            return

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
            'app/course/assignment/services'
            'app/course/team/services'
        ], ->

            isMobile = mobilecheck.isMobile()

            getAllData = (service, $scope, resource) ->
                service.all(resource).getList().then (items) ->
                    $scope[resource] = items

            getTemplate = (name) ->
                template = templates[name]

                if isMobile and templates.hasOwnProperty("#{name}_mobile")
                    template = templates["#{name}_mobile"]
                return template

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
                        syllabus:
                            restful: true
                            template: 'syllabus'
                            # controller: 'SyllabusController'
            }

            recursiveResourceFinder = (parent, resource) ->
                for item, options of parent
                    if item.indexOf(resource) is 0 and resource.indexOf(item) is 0
                        # console.log "Found #{resource}!", item, options
                        return {resource: item, options: options}
                    else if options.nested?
                        # console.log "Searching for nested resource in #{item}: ",options
                        nested = recursiveResourceFinder(options.nested, resource)
                        if nested
                            return nested
                return null

            createRoute = ($routeProvider, route, name, data) ->
                console.log "Building routes for #{name}: #{route}"
                $routeProvider.when route, {
                    template: ($routeParams) ->
                        resource = ""
                        locationParts = window.location.pathname.split('/')
                        if locationParts.length > 3
                            resource = locationParts[-3..-3] + ""
                        else
                            resource = locationParts[-1..-1] + ""

                        $routeParams.resource = resource

                        if resource
                            options = routeMap[resource] or recursiveResourceFinder(routeMap, resource)?.options
                            # console.log "Options for #{resource}", options
                            return getTemplate(unless options.restful then options.template else "#{$routeParams.action}-#{options.template}")
                        return
                    controller: if data.controller then data.controller else "#{name[0].toUpperCase()}#{name[1..-1]}Controller"
                }

            recursiveRouteBuilder = ($routeProvider, routes, baseURL) ->
                for name, data of routes
                    route = baseURL + "/#{name}"
                    if data.restful
                        route += "/:action/:id"
                    createRoute($routeProvider, route, name, data)

                    if data.nested?
                        recursiveRouteBuilder($routeProvider, data.nested, "/#{name}/:parentAction/:parentId")

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
                    Course.all().then (courses) ->
                        $scope.courses = courses

                    # $scope.useLocalData = $localStorage.useLocalData
                    $scope.updateDataURL = () ->
                        $scope.$storage.useLocalData = !$scope.$storage.useLocalData

                        url = 'http://localhost:8000'
                        unless $scope.$storage.useLocalData
                            url = 'http://django-archangel.rhcloud.com'

                        Restangular.setBaseUrl "#{url}/"

                        $location.path('/')

                .controller 'SidebarController', ($scope, $location, $routeParams, Restangular, User, Course) ->
                    $scope.isMobile = isMobile
                    $scope.user = User
                    $scope.routeParams = $routeParams

                    if User.authenticated
                        Course.all().then (courses) ->
                            $scope.courses = courses
                            for course in $scope.courses
                                Course.upcomingAssignments(course.id).then (upcoming) =>
                                    course.upcoming = upcoming
                        $scope.moment = moment
                        unless isMobile
                            getAllData(Restangular, $scope, 'users')

                .controller 'ArchangelController', ($scope, $location, Restangular, User, Course) ->
                    $scope.isMobile = isMobile
                    $scope.user = User

                    unless User.authenticated
                        $location.path('/login')
                    else
                        Course.all().then (courses) ->
                            $scope.courses = courses
                            for course in $scope.courses
                                Course.upcomingAssignments(course.id).then (upcoming) =>
                                    course.upcoming = upcoming
                        $scope.moment = moment
                        unless isMobile
                            getAllData(Restangular, $scope, 'users')


            angular.bootstrap document, ['djangoApp']
