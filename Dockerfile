FROM node:6

# Expose the HTTP port for OpenMCT
EXPOSE 8080
# Export the Websocket port for OpenMCT live telemetry
EXPOSE 8082

# Reduce npm install verbosity, overflows Travis CI log view
ENV NPM_CONFIG_LOGLEVEL warn

RUN mkdir -p /var/cbeam-telemetry-server
WORKDIR /var/cbeam-telemetry-server

COPY . /var/cbeam-telemetry-server

# Install MsgFlo and dependencies
RUN npm install

CMD npm start
