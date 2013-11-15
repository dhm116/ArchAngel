define ['angular'], (angular) ->
        class BaseService
            items: []
            $q: null
            model: null
            defer: null

            constructor: (@Restangular, @$q) ->
                @__onNewInstance(Array.prototype.slice.call(arguments)[2..-1]...)
                return

            __onNewInstance: () =>
                return

            __checkDependencies: =>
                errors = []
                unless @model
                    errors.push new Error('model not defined')
                unless @Restangular
                    errors.push new Error('Restangular reference not provided')
                unless @$q
                    errors.push new Error('$q reference not provided')

                throw error for error in errors

            all: (ids) =>
                @__checkDependencies()
                unless @defer?
                    @defer = @$q.defer()

                    unless Array.isArray(ids)
                        ids = [ids] if ids?

                    unless @items.length
                        console.log "Loading #{@model} data from REST API"
                        @Restangular.all(@model).getList().then (items) =>
                            console.log "Got #{@model} data"
                            @items = items
                            # console.log @items
                            @defer.resolve(if ids then @__getItems(ids) else @items)
                    else
                        console.log "Loading cached #{@model} items"
                        @defer.resolve(if ids then @__getItems(ids) else @items)

                return @defer.promise

            get: (id) =>
                @__checkDependencies()
                defer = @$q.defer()

                match = _.findWhere(@items, {id: id})
                if match
                    console.log "Loading cached single #{@model} item"
                    # console.log @items
                    defer.resolve(match)
                else
                    console.log "Loading single #{@model} from REST API"
                    # @Restangular.one(@model, id).get().then (item) =>
                    #     console.log "Got single #{@model} data"
                    @items = []
                    @all().then =>
                        # unless _.contains(@items, item)
                            # @items.push item
                        defer.resolve(_.findWhere(@items, {id: id}))

                return defer.promise

            add: (item) =>
                defer = @$q.defer()
                @Restangular.all(@model).post(item)
                    .then (result) =>
                        defer.resolve(result)
                    .catch (err) =>
                        defer.reject(err)
                return defer.promise

            update: (item) =>
                defer = @$q.defer()
                if item.put
                    console.log "Updating existing restangular object: ", item
                    request = item.put()
                else
                    defer.reject(new Error('An existing restangular object is required for updating'))
                #     console.log "Loading reference to #{@model}.#{item.id}: ", item
                #     request = @Restangular.one(@model, item.id).put(item)

                request.then (result) =>
                        defer.resolve(result)
                    .catch (err) =>
                        defer.reject(err)
                return defer.promise

            __getItems: (ids) =>
                unless _.every(ids, _.isNumber)
                    return ids

                return _.filter @items, (item) =>
                    _.contains(ids, item.id)


        return BaseService
