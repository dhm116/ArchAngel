# require
#   urlArgs: "b=#{(new Date()).getTime()}"
#   paths:
#     jquery: 'vendor/jquery/jquery'
#   , ['app/example-view']
#   , (ExampleView) ->
#     view = new ExampleView()
#     view.render('body')

# $ ->
    # djangoApp = angular.module('djangoServices', ['ngResource'])
    #     .factory 'User', ($resource) ->
    #         $resource('http://macpro.local:8000/users.json', {}, {
    #             query: {method:'GET', isArray:true}
    #         })


    # app = angular.module('djangoApp', ['djangoServices'])
    # UserController = app.controller 'UserController', ['$scope', '$routeParams', 'User', ($scope, User) ->
    #     $scope.users = User.query()
    # ]

require
    urlArgs: "b=#{(new Date()).getTime()}"
    paths:
        jquery: 'vendor/jquery/jquery'
        angular: 'vendor/angular/angular'
    ,    () ->
        app = angular.module('djangoApp', ['djangoApp.restangular', 'djangoApp.controllers']).config ['$routeProvider', ($routeProvider) ->

        ]

        rest = angular.module('djangoApp.restangular', ['restangular'])

        angular.module('djangoApp.controllers', ['djangoApp.restangular']).controller 'UserController', ($scope, Restangular) ->
            Restangular.setBaseUrl 'http://macpro.local:8000/'
            Restangular.setRequestSuffix '/?format=json'

            $scope.users = Restangular.allUrl('users', "users").getList()

        angular.bootstrap document, ['djangoApp']

        app.run ['$rootScope', '$log', ($rootScope, $log) ->

        ]
