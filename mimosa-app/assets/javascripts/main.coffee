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
    #     angular: 'angular'
    #     # views: 'app/example-view'
    ,[
        'angular'
        'templates'
        'app/mobile-check'
    ]
    ,(angular, templates, mobilecheck) ->
        $(document).foundation()

        $.get ''

        token = null

        isMobile = mobilecheck.isMobile()

        getAllData = (service, $scope, resource) ->
            service.all(resource).getList().then (items) ->
                $scope[resource] = items

        getTemplate = (name) ->
            template = templates[name]

            if isMobile and templates.hasOwnProperty("#{name}_mobile")
                template = templates["#{name}_mobile"]
            return template

        angular.module('configuration', [])
            .constant('BASE_URL', 'http://localhost:8000') #'http://django-archangel.rhcloud.com')

        angular.module('djangoApp.services', ['configuration'])
        angular.module('djangoApp.controllers', ['restangular', 'djangoApp.services', 'configuration'])
            .config (RestangularProvider, BASE_URL) ->
                RestangularProvider.setBaseUrl "#{BASE_URL}/" #'http://django-archangel.rhcloud.com/'
                RestangularProvider.setRequestSuffix '/?format=json'

        require [
            'app/login/services'
            'app/login/controllers'
            'app/course/services'
            'app/course/controllers'
        ], ->
            app = angular.module('djangoApp', [
                    'ngRoute'
                    'ngCookies'
                    'djangoApp.controllers'
                    'chieffancypants.loadingBar'
                ]
                , ($routeProvider, $locationProvider) ->
                    $routeProvider.when '/login', {
                            template: templates['login']
                            controller: 'LoginController'
                    }
                    $routeProvider.when '/Course/:courseId', {
                            template: templates['course-main']
                            controller: 'CourseController'
                    }
                    $routeProvider.when '/Students', {
                            template: templates['students']
                            controller: 'StudentController'
                    }
                    $routeProvider.otherwise {
                            template: getTemplate('main-screen') #templates['main-screen']
                            controller: 'ArchangelController'
                    }
                    $locationProvider.html5Mode(true)
            )

            angular.module('djangoApp.controllers') #, ['restangular', 'djangoApp.services'])
                .controller 'NavbarController', ($scope,$location, Restangular, User, Course) ->
                    $scope.isMobile = isMobile
                    $scope.user = User

                    $scope.useLocalData = true
                    $scope.updateDataURL = () ->
                        $scope.useLocalData = !$scope.useLocalData

                        url = 'http://localhost:8000'
                        unless $scope.useLocalData
                            url = 'http://django-archangel.rhcloud.com'

                        angular.module('configuration')
                            .constant('BASE_URL', url)
                        Restangular.setBaseUrl "#{url}/"

                        $location.path('/')

                .controller 'ArchangelController', ($scope, Restangular, User, Course) ->
                    $scope.isMobile = isMobile

                    unless isMobile
                        getAllData(Restangular, $scope, 'users')


                .controller 'StudentController', ($scope, $route, $routeParams, $location, Restangular) ->
                    getAllData(Restangular, $scope, 'students')


            angular.bootstrap document, ['djangoApp']
