FROM gitpod/workspace-full

RUN sudo apt-get update

RUN sudo && apt -y install asciidoc \
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
	sudo \
    git

RUN git clone https://github.com/ilpincy/argos3

WORKDIR argos3
RUN mkdir build_simulator
WORKDIR build_simulator
RUN cmake ../src
RUN make
