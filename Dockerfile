FROM debian:latest
MAINTAINER Rasmus Munk <rasmus.munk@nbi.ku.dk>

RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    openssh-server \
    python3-dev \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir -p /run/sshd

COPY main.py /app/main.py
COPY requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip3 install setuptools wheel
RUN pip3 install -r requirements.txt
RUN useradd -ms /bin/bash mountuser
RUN echo 'mountuser:Passw0rd!' | chpasswd

EXPOSE 22

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

CMD ["/usr/bin/python3", "/app/main.py"]
