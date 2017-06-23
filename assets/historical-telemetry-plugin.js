/**
 * Basic historical telemetry plugin.
 */

function HistoricalTelemetryPlugin(namespaces) {
    return function install (openmct) {
        var provider = {
            supportsRequest: function (domainObject) {
                if (namespaces.indexOf(domainObject.type) === -1) {
                  return false;
                }
                return true;
            },
            request: function (domainObject, options) {
                var url = '/telemetry/' +
                    domainObject.identifier.key +
                    '?start=' + options.start +
                    '&end=' + options.end;

                return http.get(url)
                    .then(function (resp) {
                        return resp.data;
                    });
            }
        };

        openmct.telemetry.addProvider(provider);
    }
}
