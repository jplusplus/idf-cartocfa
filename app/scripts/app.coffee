angular.module('app.animation', [])
angular.module('app.constant',  [])
angular.module('app.config',    [])
angular.module('app.controller',[])
angular.module('app.directive', [])
angular.module('app.filter',    [])
angular.module('app.service',   [])
angular.module('app.template',  [])

app = angular.module 'app', [
    # Angular dependencies
    "ngRoute"
    "ngResource"
    "ngAnimate"
    "ngSanitize"
    "leaflet-directive"
    "truncate"
    "siyfion.sfTypeahead"
    "angulartics"
    "angulartics.google.analytics"
    # Internal dependencies
    "app.animation"
    "app.constant"
    "app.controller"
    "app.config"
    "app.filter"
    "app.service"
    "app.directive"
    "app.template"
]
# EOF
