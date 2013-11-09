tests = Object.keys(window.__karma__.files).filter (file) ->
    return /\.*spec\.js$/.test(file)

console.log tests
requirejs
    baseUrl: '/base/public/javascripts'
    shim:
        'angular': {'exports':'angular'}
    paths:
        angular: 'vendor/angular/angular'
    #     mobilecheck: 'app/mobile-check'
        # djangoApp: 'app/app'
    deps: tests
    callback: window.__karma__.start
