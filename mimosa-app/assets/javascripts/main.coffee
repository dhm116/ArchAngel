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
        # showdown: 'vendor/showdown/showdown'
    #     angular: 'angular'
    #     # views: 'app/example-view'
    ,[
        'angular'
        'templates'
        'app/mobile-check'
    ]
    ,(angular, templates, mobilecheck) ->
        $(document).foundation()

        #$.get ''

        #token = null

        isMobile = mobilecheck.isMobile()

        getAllData = (service, $scope, resource) ->
            service.all(resource).getList().then (items) ->
                $scope[resource] = items

        getTemplate = (name) ->
            template = templates[name]

            if isMobile and templates.hasOwnProperty("#{name}_mobile")
                template = templates["#{name}_mobile"]
            return template

        angular.module('configuration', ['restangular','ngStorage'])
            .config (RestangularProvider) ->
                RestangularProvider.setRequestSuffix '/?format=json'
            .constant('BASE_URL', {
                local: 'http://localhost:8000'
                cloud: 'http://django-archangel.rhcloud.com'
            })
            .run (Restangular, $localStorage, BASE_URL) ->
                Restangular.setBaseUrl if $localStorage.useLocalData then BASE_URL.local else BASE_URL.cloud #"#{BASE_URL}/" #'http://django-archangel.rhcloud.com/'

        angular.module('djangoApp.services', ['configuration', 'ngStorage'])
        angular.module('djangoApp.controllers', ['restangular', 'djangoApp.services', 'configuration', 'ngStorage'])

        require [
            'app/login/services'
            'app/login/controllers'
            'app/course/services'
            'app/course/controllers'
            'app/course/roster/services'
            'app/course/section/services'
            'app/course/section/controllers'
            'app/course/syllabus/services'
            'app/course/lesson/services'
        ], ->
            app = angular.module('djangoApp', [
                    'ngRoute'
                    'djangoApp.controllers'
                    'chieffancypants.loadingBar'
                    'btford.markdown'
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
                    $routeProvider.when '/Course/:courseId/sections/:sectionId', {
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
                .controller 'NavbarController', ($scope,$location,$localStorage,Restangular, BASE_URL, User, Course) ->
                    $scope.$storage = $localStorage.$default {useLocalData: true}
                    $scope.isMobile = isMobile
                    $scope.user = User

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

                    unless isMobile
                        getAllData(Restangular, $scope, 'users')
                        # getAllData(Restangular, $scope, 'upcoming-assignments')


                .controller 'StudentController', ($scope, $route, $routeParams, $location, Restangular) ->
                    getAllData(Restangular, $scope, 'students')


            angular.bootstrap document, ['djangoApp']
