FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

MAINTAINER Neocortex R&D "hello@neocortexlab.io"

ENV PATH /opt/conda/bin:$PATH
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH 

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
                wget \
                curl \
                git \
    		build-essential \
                locales \
                libatlas-base-dev \
    && rm -rf /var/lib/apt/lists/*


ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

RUN curl https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb > /tmp/erlang-solutions_1.0_all.deb && \
    dpkg -i /tmp/erlang-solutions_1.0_all.deb && \
    apt-get update -qq && apt-get install -y esl-erlang elixir && \
    mix local.rebar --force && \
    mix local.hex --force

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN pip install --upgrade pip && pip install numpy keras erlport

RUN wget --quiet https://pallium.nyc3.digitaloceanspaces.com/tensorflow-1.10.0-cp36-cp36m-linux_x86_64.whl && \
    pip install tensorflow-1.10.0-cp36-cp36m-linux_x86_64.whl && \
    rm tensorflow-1.10.0-cp36-cp36m-linux_x86_64.whl

RUN curl -L https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-gpu-linux-x86_64-1.10.0.tar.gz | \
    tar -C /usr/local -xz

#RUN curl -O https://storage.googleapis.com/golang/go1.11.linux-amd64.tar.gz && \
#    tar -C /usr/local -xvf go1.11.linux-amd64.tar.gz && \
#    rm go1.11.linux-amd64.tar.gz && \
#    export PATH="/usr/local/go/bin:$PATH"
#
#RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

#RUN go get -u -d github.com/ipfs/go-ipfs && cd "$GOPATH/src/github.com/ipfs/go-ipfs" && make install && make build
#RUN go get -u -d github.com/tendermint/tendermint/cmd/tendermint && cd "$GOPATH/src/github.com/tendermint/tendermint" && make install

RUN git clone https://github.com/neocortexlab/pallium.git && cd /pallium && mix deps.get && mix deps.compile
CMD [ "/bin/bash" ]
