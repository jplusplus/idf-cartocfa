angular.module("app.service").factory("Filters", ()->
        new class Filters
            # Private Attributes
            filters =
                level  : null
                sector : null
                filiere: null
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
)
