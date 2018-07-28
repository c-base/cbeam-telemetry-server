FROM resin/raspberrypi3-node:8

# Expose the HTTP port for OpenMCT
EXPOSE 8080
# Export the Websocket port for OpenMCT live telemetry
EXPOSE 8082

# Reduce npm install verbosity, overflows Travis CI log view
ENV NPM_CONFIG_LOGLEVEL warn
# Install only production dependencies since we're copying OpenMCT from outside
ENV NODE_ENV production

RUN mkdir -p /var/cbeam-telemetry-server
WORKDIR /var/cbeam-telemetry-server

COPY . /var/cbeam-telemetry-server

# Install MsgFlo and dependencies
RUN npm install --only=production

# Set OpenMCT location
ENV OPENMCT_ROOT openmct

# Map the volumes
VOLUME /var/cbeam-telemetry-server/config

CMD ./server.sh
