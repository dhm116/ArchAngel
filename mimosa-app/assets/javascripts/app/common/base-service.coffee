'use strict'

define ['angular'], (angular) ->
    # ##Base Service
    # This service contains the core logic for handling our
    # restful resources using `Restangular` .
    class BaseService
        items: []
        $q: null
        model: null
        defer: null

        # Primary constructor for the Base Service class,
        # relying upon (at a minimum) the `Restangular` ,
        # `$rootScope` and promise (`$q`) services.
        #
        # Additional arguments will be lumped into "other".
        constructor: (@Restangular, @$q, @$rootScope, other...) ->
            # Hand off any additional arguments to any
            # sub class that overrides this method.
            @__onNewInstance(other...)
            return

        # Intended to be overridden by sub classes.
        #
        # Used during instantiation of the class.
        __onNewInstance: () =>
            return

        # Verify any dependent properties have been
        # defined by the sub class.
        __checkDependencies: =>
            errors = []
            unless @model
                errors.push new Error('model not defined')
            unless @Restangular
                errors.push new Error('Restangular reference not provided')
            unless @$q
                errors.push new Error('$q reference not provided')

            throw error for error in errors

        # Retrieves all items and optionally returns
        # a subset matching the supplied ids.
        #
        # `ids` can be null, a single number, or an array
        # of numbers.
        #
        # `forceUpdate` is a boolean that will refresh the
        # local object cache for this model.
        all: (ids, forceUpdate) =>
            # Let's make sure any overriden models have actually
            # defined what model to load, and any dependencies to
            # load it.
            @__checkDependencies()

            # Set up our promise object to return async results.
            defer = @$q.defer()

            # Let's choose to only handle arrays.
            unless _.isArray(ids)
                # But only if they actually provided some ids.
                ids = [ids] if ids?

            # If we already have loaded all data, let's use
            # the cached version we already have.
            if forceUpdate
                @items = []

            # If we have no cached data, make a new request.
            unless @items.length
                console.log "Loading #{@model} data from REST API"
                # It's safe to call `Restangular.all` because the
                # back-end is scoping all results to those that
                # the logged in users is authorized to see.
                @Restangular.all(@model).getList()
                    .then (items) =>
                        console.log "Got #{@model} data"
                        if items.length
                            @items = items

                            # Complete the promise either with all items
                            # returned, or with a filtered list of items
                            # based on the ids supplied
                            defer.resolve(if ids then @__getItems(ids) else @items)

                            @$rootScope.$broadcast "#{@model}-updated", @
                        else
                            defer.resolve(@items)
                    .catch (err) =>
                        defer.reject(err)
                        @$rootScope.$broadcast "error", {service: @, error: err}

            else
                console.log "Loading cached #{@model} items"
                # Complete the promise either with all items
                # returned, or with a filtered list of items
                # based on the ids supplied
                defer.resolve(if ids then @__getItems(ids) else @items)

            # This gets returned "immediately" and will
            # be invoked later
            return defer.promise

        # Retrieves a single item
        #
        # `id` must be a number
        #
        # `forceUpdate` is a boolean that will refresh the
        # local object cache for this model.
        get: (id, forceUpdate) =>
            @__checkDependencies()
            defer = @$q.defer()

            match = _.findWhere(@items, {id: id})
            if match or forceUpdate
                console.log "Loading cached single #{@model} item"
                defer.resolve(match)
            else
                console.log "Loading single #{@model} from REST API"
                @items = []
                @all().then =>
                    defer.resolve(_.findWhere(@items, {id: id}))

            return defer.promise

        # Adds a new item and issues an HTTP POST
        add: (item) =>
            defer = @$q.defer()
            @Restangular.all(@model).post(item)
                .then (result) =>
                    # Add the item to the local cache
                    @items.push(result)
                    defer.resolve(result)
                    @$rootScope.$broadcast "#{@model}-updated", @
                .catch (err) =>
                    defer.reject(err)
                    @$rootScope.$broadcast "error", {service: @, error: err}
            return defer.promise

        # Updates an existing item and issues an
        # HTTP PUT
        update: (item) =>
            defer = @$q.defer()
            if item.put
                console.log "Updating existing restangular object: ", item
                request = item.put()
            else
                defer.reject(new Error('An existing restangular object is required for updating'))

            request.then (result) =>
                    # Update the local cache instance
                    index = @items.indexOf(_.findWhere(@items, {id: result.id}))
                    @items[index] = result
                    defer.resolve(result)
                    @$rootScope.$broadcast "#{@model}-updated", @
                .catch (err) =>
                    defer.reject(err)
                    @$rootScope.$broadcast "error", {service: @, error: err}
            return defer.promise

        # Deletes an existing item and issues an
        # HTTP DELETE
        delete: (item) =>
            defer = @$q.defer()

            id = if _.isNumber(item) then item else item.id

            console.log "Deleting #{@model} #{id}"

            @Restangular.one(@model, id).remove().then (result) =>
                    # Update the local cache instance
                    index = @items.indexOf(_.findWhere(@items, {id: id}))
                    delete @items[index]
                    defer.resolve(result)
                    @$rootScope.$broadcast "#{@model}-updated", @
                .catch (err) =>
                    defer.reject(err)
                    @$rootScope.$broadcast "error", {service: @, error: err}
            return defer.promise

        # Gets all items from the local cache that
        # match a given set of ids
        __getItems: (ids) =>
            unless _.every(ids, _.isNumber)
                return ids

            return _.filter @items, (item) =>
                _.contains(ids, item.id)


    return BaseService
