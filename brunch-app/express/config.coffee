exports.config =
    view:
        engine: 'jade'
    cookie:
        secret: 'Express Brunch Rules!'
    db: # Will default to in-memory if none defined

        # Redis options
        type: 'redis'
        options:
            port: 6379
        # Postgres options
        # type: 'postgres'
        # options:
        #     database: 'archangel'
        #     username: 'archangel'
        #     password: 'archangel'