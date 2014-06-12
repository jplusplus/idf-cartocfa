class PopupCtrl
    @$inject: ['$scope', '$location', 'Filters']
    constructor: (@scope, @location, @Filters)->
        @scope.filters = @Filters
        # Update the location
        @scope.selectCfa = (rne)=> @location.search 'rne', rne

angular.module('app.controller').controller "PopupCtrl", PopupCtrl