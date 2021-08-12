FROM node:16

RUN apt update && apt -y install asciidoc \
	cmake \
	doxygen \
	freeglut3-dev \
	graphviz \
	libfreeimage-dev \
	libfreeimageplus-dev \
	libgraphviz-dev \
	liblua5.3-dev \
	libxi-dev \
	libxmu-dev \
	lua5.3 \
	qt5-default \
	sudo

WORKDIR /usr/src/bot

COPY selfdom.tar .
RUN tar -xvf selfdom.tar
RUN mv selfdom-master selfdom
#COPY install.sh selfdom/
# required due to some fixes... but shouldnt be required since gitlab repo since up to date
WORKDIR /usr/src/bot/selfdom
RUN bash install.sh

wORKDIR /usr/src/bot/selfdom/exp_prosoc/
ENV LD_LIBRARY_PATH=/usr/local/lib/argos3/
#example of running a simulation
#RUN cd /usr/src/bot/selfdom/exp_prosoc/ && ./runExpBatch.sh 1000 0.9

# Create app directory
WORKDIR /usr/src/app
RUN openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhttps" \
    -keyout localhttps.key  -out localhttps.cert

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
RUN npm install -g nodemon
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY . .

# to have your own Jupyter local environment uncomment the next line
# RUN apt install -y python3-pip && pip3 install jupyterlab
# you can then run the following command in the container
# jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.token=''
# then open this page in your browser
# http://127.0.0.1:8888/lab/workspaces/auto-V/tree/argos.ipynb

EXPOSE 8080
# http for reverse proxying with e.g nginx or traefik
EXPOSE 8443
# https for local testing with a https page e.g ObservableHQ
EXPOSE 8888
# http for local Jupyter Lab

#CMD [ "node", "server.js" ]
CMD [ "nodemon", "server.js" ]
