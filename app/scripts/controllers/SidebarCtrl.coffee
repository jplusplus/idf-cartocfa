class SidebarCtrl
    @$inject: ['$scope', '$http', '$location', 'Filters', 'Dataset']
    constructor: (@scope, @http, @location, @Filters, @Dataset)->
        @empty = []
        # Filter to display
        @shouldShowFilter = 'sector'
        @shouldShowSector = null
        # ──────────────────────────────────────────────────────────────────────
        # Methods and attributes available within the scope
        # ──────────────────────────────────────────────────────────────────────
        @scope.places       = []
        @scope.filters      = @Filters
        @scope.getAddress   = @getAddress
        @scope.shouldShowFilter = (filter)=> @shouldShowFilter is filter
        @scope.shouldShowSector = (sector)=> @shouldShowSector is sector
        # Toggle some elements
        @scope.toggleFilter = (f)=>
            @shouldShowFilter = if @shouldShowFilter is f then null else f
            # Activate the given filter
            @Filters.activate f
        @scope.toggleSector = (s)=> @shouldShowSector = if @shouldShowSector is s then null else s
        # Update map center
        @scope.setCenter    = @setCenter
        # Close single mode
        @scope.closeSingle  = => @location.search "rne", null
        # Filter map
        @scope.filterBy     = @filterBy
        @scope.removeFilter = @removeFilter
        @scope.getSectors   = @getSectors
        @scope.getFilieres  = @getFilieres
        @scope.getLevels    = @getLevels
        # Active values
        @scope.getActiveSector  = @getActiveSector
        @scope.getActiveFiliere = @getActiveFiliere
        @scope.getActiveLevel   = @getActiveLevel

        # ──────────────────────────────────────────────────────────────────────
        # Watchers
        # ──────────────────────────────────────────────────────────────────────
        # Save spaces as an array (instead of an objects)
        @scope.$watch (=>@Dataset.markers.all), (d)=>
            @scope.places = _.map _.values(d), (place)->
                name: place.name
                rne: place.rne
        , yes

        @scope.$on '$typeahead.select', (ev, val)=>
            switch @shouldShowFilter
                when 'name'  then @filterBy 'name', val.name
                when 'place' then @setCenter val


    setCenter: (addr)=>
        # Geocode the address asynchronously
        @getAddress addr, (err, res)=>
            unless err? or res.length is 0
                angular.extend @Filters.centers.manual, res[0].geometry.location
                angular.extend @Filters.centers.manual, zoom: 14


    filterBy: (filter, value)=>
        # Hide the menu
        @shouldShowSector = null
        # Update filter
        @Filters.set filter, value

    removeFilter: (filter)=>
        # Hide the menu
        @shouldShowSector = null
        # Update filter
        @Filters.set filter, null

    # Get filters sets
    getSectors: =>
        @Dataset.tree

    getFilieres: =>
        sector   = _.findWhere @getSectors(), name: @Filters.active('sector')
        if sector? and sector.filieres? then sector.filieres else @empty

    getLevels: =>
        filiere =  _.findWhere @getFilieres(), name: @Filters.active('filiere')
        if filiere? and filiere.levels? then filiere.levels else @empty

    # Get filters displays
    getActiveSector : (alt="Tous")=> @Filters.active('sector') or alt
    getActiveFiliere: (alt="Tous")=> @Filters.active('filiere') or alt
    getActiveLevel  : (alt="Tous")=> @Filters.active('level') or alt

    getAddress: (viewValue, callback=->)=>
        return callback(error: 'No value', null) unless viewValue?
        params = address: viewValue + ", Île-de-France", sensor: no
        # Use Google Map's API to geocode the given address
        url = "http://maps.googleapis.com/maps/api/geocode/json"
        @http.get(url, params: params).then (res)->
            if res.data.results.length and
               res.data.results[0].formatted_address is "Île-de-France, France"
                # No result
                res.data.results = []
            callback null, res.data.results
            res.data.results





angular.module('app.controller').controller "SidebarCtrl", SidebarCtrl
