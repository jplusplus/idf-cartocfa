angular.module("app.service").factory("Filters", ()->
    new class Filters
        # Private Attributes
        filters =
            sector : null
            filiere: null
            level  : null
            name   : null
        active = null
        # Map centers
        centers:
            default:
                lat: 48.856583
                lng: 2.3510745
                zoom: 11
            manual:
                lat: 48.856583
                lng: 2.3510745
                zoom: 11
        KEYS:
            SECTOR: ['sector', 'filiere', 'level']
            PLACE : ['place']
            NAME  : ['name']
        # ─────────────────────────────────────────────────────────────────
        # Public method
        # ─────────────────────────────────────────────────────────────────
        constructor: -> [filters, active]
        # Setter
        set: (name, value)=>
            filters[name] = value
            # Filter by sector
            if _.contains @KEYS.SECTOR, name
                @activate('sector')
            # Filter by name of place
            else
                @activate(name)
        activate: (name)=> active = name
        # Getter
        get: (name)=> if name? then filters[name] else [filters, active]
        active: (o=active)=> filters[o]
)
