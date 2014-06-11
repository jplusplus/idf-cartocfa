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
        # ─────────────────────────────────────────────────────────────────
        # Public method
        # ─────────────────────────────────────────────────────────────────
        constructor: -> [filters, active]
        # Setter
        set: (name, value)=>
            filters[name] = value
            active = if value is null then null else name
        # Getter
        get: => [filters, active]
        active: (o=active)=> filters[o]
)
