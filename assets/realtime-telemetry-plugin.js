/**
 * Basic Realtime telemetry plugin using websockets.
 */
function RealtimeTelemetryPlugin(namespaces) {
    return function (openmct) {
        var socket = new WebSocket('ws://' + window.location.hostname + ':8082');
        var listeners = {};

        socket.onmessage = function (event) {
            point = JSON.parse(event.data);
            if (listeners[point.id]) {
                listeners[point.id].forEach(function (l) {
                    l(point);
                });
            }
        };

        var provider = {
            supportsSubscribe: function (domainObject) {
                if (namespaces.indexOf(domainObject.type) === -1) {
                  return false;
                }
                return true;
            },
            subscribe: function (domainObject, callback, options) {
                if (!listeners[domainObject.identifier.key]) {
                    listeners[domainObject.identifier.key] = [];
                }
                if (!listeners[domainObject.identifier.key].length) {
                    socket.send('subscribe ' + domainObject.identifier.key);
                }
                listeners[domainObject.identifier.key].push(callback);
                return function () {
                    listeners[domainObject.identifier.key] =
                        listeners[domainObject.identifier.key].filter(function (c) {
                            return c !== callback;
                        });

                    if (!listeners[domainObject.identifier.key].length) {
                        socket.send('unsubscribe ' + domainObject.identifier.key);
                    }
                };
            }
        };
        openmct.telemetry.addProvider(provider);
    }
}
