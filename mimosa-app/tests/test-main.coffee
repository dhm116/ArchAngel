tests = Object.keys(window.__karma__.files).filter (file) ->
    return /\.*spec\.js$/.test(file)

requirejs
    baseUrl: '/base/public/javascripts'
    
    paths:
        'angular' : 'vendor/angular/angular'
        'angular-mocks': 'vendor/angular-mocks/angular-mocks'
        'angular-resource': 'vendor/angular-resource/angular-resource'
        'angular-route': 'vendor/angular-route/angular-route'
        'restangular': 'vendor/restangular/restangular.min'
        'underscore': 'vendor/underscore/underscore'
        'ngStorage': 'vendor/ngstorage/ngStorage'
        'loading-bar': 'vendor/angular-loading-bar/loading-bar'
        'markdown': 'vendor/angular-markdown-directive/markdown'


    shim:
        'angular': {'exports':'angular'}
        'angular-mocks': { deps:['angular'], 'exports':'AngularMocks'}
        'angular-route': { deps:['angular'], 'exports':'AngularRoute'}
        'angular-resource': { deps:['angular'], 'exports':'AngularResource'}
        'underscore': {'exports': '_'}
        'restangular': { deps:['angular', 'underscore'], 'exports':'Restangular'}
        'ngStorage': {deps:['angular']}
        'loading-bar': {deps:['angular']}
        'markdown': {deps:['angular']}


    deps: tests

    callback: window.__karma__.start
