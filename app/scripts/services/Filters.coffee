angular.module("app.service").factory("Filters", ()->
        new class Filters
            # Private Attributes
            filters =
                sector : null
                filiere: null
                level  : null
            active = null
            # ─────────────────────────────────────────────────────────────────
            # Public method
            # ─────────────────────────────────────────────────────────────────
            constructor: -> [filters, active]
            # Setter
            set: (name, value)=> 
                filters[name] = value
                active = name
            # Getter
            get: => [filters, active]
            active: (o=active)=> filters[o]
)
