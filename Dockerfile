FROM alpine

RUN apk fix && \
    apk --no-cache --update add git bash git-lfs gpg less openssh patch perl && \
    apk --no-cache --update add curl coreutils && \
    git lfs install

ENV DDNS_HOST "gitlab.com"
ENV DDNS_SSH_REPO ""
ENV DDNS_SSH_KEY ""
ENV DDNS_SSH_PASSPHRASE ""
ENV DDNS_GIT_USERNAME "DDNS Updater"
ENV DDNS_GIT_EMAIL "ddns.updater@gmail.com"
ENV DDNS_TIMEOUT "20m"

#run keyscan, otherwise you will not be able to push to repo
RUN mkdir -p -m 0600 /root/.ssh
RUN ssh-keyscan ${DDNS_HOST} >> /root/.ssh/known_hosts
COPY config /root/.ssh
RUN chmod 0600 /root/.ssh/config

WORKDIR /app

COPY ddns.sh .
COPY ssh_give_pass.sh .

ENTRYPOINT ["/bin/bash", "ddns.sh"]
