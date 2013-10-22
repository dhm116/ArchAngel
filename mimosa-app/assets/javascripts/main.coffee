require
    urlArgs: "b=#{(new Date()).getTime()}"
    paths:
        jquery: 'vendor/jquery/jquery'
        angular: 'vendor/angular/angular'
    ,    () ->
        $(document).foundation()

        $.get ''

        getAllData = (service, $scope, resource) ->
            service.all(resource).getList().then (items) ->
                $scope[resource] = items

        app = angular.module('djangoApp', ['djangoApp.controllers'])

        angular.module('djangoApp.controllers', ['restangular']).controller 'ArchangelController', ($scope, Restangular) ->
            Restangular.setBaseUrl 'http://macpro.local:8000/'
            Restangular.setRequestSuffix '/?format=json'

            getAllData(Restangular, $scope, 'users')
            getAllData(Restangular, $scope, 'courses')

        angular.bootstrap document, ['djangoApp']
