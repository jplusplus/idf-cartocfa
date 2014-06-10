class SidebarCtrl
    @$inject: ['$scope', 'Filters', 'Dataset']
    constructor: (@scope, @Filters, @Dataset)->
        @empty = []
        # Filter to display
        @shouldShowFilter = 'search-sector'
        @shouldShowSector = null
        @scope.filters    = @Filters
        # ──────────────────────────────────────────────────────────────────────
        # Methods available within the scope
        # ──────────────────────────────────────────────────────────────────────
        @scope.shouldShowFilter = (filter)=> @shouldShowFilter is filter
        @scope.shouldShowSector = (sector)=> @shouldShowSector is sector
        # Toggle some elements
        @scope.toggleFilter = (f)=> @shouldShowFilter = if @shouldShowFilter is f then null else f
        @scope.toggleSector = (s)=> @shouldShowSector = if @shouldShowSector is s then null else s
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

    filterBy: (filter, value)=>
        # Hide the menu
        @shouldShowSector = null
        # Update filter
        @Filters.set filter, value
    removeFilter: (filter)=>
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





angular.module('app.controller').controller "SidebarCtrl", SidebarCtrl