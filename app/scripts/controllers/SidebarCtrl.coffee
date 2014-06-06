class SidebarCtrl
    @$inject: ['$scope', 'Filters']
    constructor: (@scope, @Filters)->
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
        @scope.filterBy = @filterBy

    filterBy: (filter, value)=>
        # Hide the menu
        @shouldShowSector = null
        # Update filter
        @Filters.set filter, value




angular.module('app.controller').controller "SidebarCtrl", SidebarCtrl