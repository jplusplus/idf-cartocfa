angular.module('app.config').config ['$analyticsProvider', ($analyticsProvider)->
    $analyticsProvider.virtualPageviews no
]
