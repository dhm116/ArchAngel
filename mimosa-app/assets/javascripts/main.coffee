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
        $(document).foundation()

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
                        lesson:
                            restful: true
                            template: 'lesson'
                        syllabus:
                            restful: true
                            template: 'syllabus'
            }

            recursiveResourceFinder = (parent, resource) ->
                for item, options of parent
                    if item is resource
                        return {resource: item, options: options}
                    else if options.nested?
                        nested = recursiveResourceFinder(options.nested, resource)
                        if nested
                            return nested
                return null

            createRoute = ($routeProvider, route, name, data) ->
                $routeProvider.when route, {
                    template: ($routeParams) ->
                        console.log $routeParams
                        if $routeParams?.resource?
                            resource = $routeParams.resource
                            options = routeMap[resource] or recursiveResourceFinder(routeMap, resource)?.options
                            return getTemplate(unless options.restful? then options.template else "#{$routeParams.action}-#{options.template}")
                        return
                    controller: if data.controller? then data.controller else "#{name[0].toUpperCase()}#{name[1..-1]}Controller"
                }

            recursiveRouteBuilder = ($routeProvider, routes, baseURL) ->
                for name, data of routes
                    route = baseURL + "/:resource/:action/:id"
                    createRoute($routeProvider, route, name, data)

                    if data.nested?
                        recursiveRouteBuilder($routeProvider, data.nested, route[0..-3]+'parentId')

            app.config ($routeProvider, $locationProvider) ->
                # $routeProvider.when '/login', {
                #         template: templates['login']
                #         controller: 'LoginController'
                # }

                recursiveRouteBuilder($routeProvider, routeMap, "")

                # $routeProvider.when '/Course/:courseId', {
                #         template: templates['course-main']
                #         controller: 'CourseController'
                # }
                # $routeProvider.when '/Course/:courseId/Syllabus/:action', {
                #         template: templates['edit-syllabus']
                #         controller: 'SyllabusController'
                # }
                # $routeProvider.when '/Course/:courseId/Lesson/:lessonId', {
                #         template: templates['lesson']
                #         controller: 'LessonController'
                # }
                # $routeProvider.when '/Course/:courseId/Lesson/add', {
                #         template: templates['edit-lesson']
                #         controller: 'LessonController'
                # }
                # $routeProvider.when '/Students', {
                #         template: templates['students']
                #         controller: 'StudentController'
                # }
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

                .controller 'ArchangelController', ($scope, Restangular, User, Course) ->
                    $scope.isMobile = isMobile
                    Course.all().then (courses) ->
                        $scope.courses = courses

                    unless isMobile
                        getAllData(Restangular, $scope, 'users')
                        # getAllData(Restangular, $scope, 'upcoming-assignments')


                # .controller 'StudentController', ($scope, $route, $routeParams, $location, Restangular) ->
                #     getAllData(Restangular, $scope, 'students')


            angular.bootstrap document, ['djangoApp']
