FROM registry.access.redhat.com/ubi8

ENV AWS_ACCESS_KEY_ID ""
ENV AWS_SECRET_ACCESS_KEY ""

# Handle prereqs
RUN dnf -y --setopt=tsflags=nodocs update && \
    dnf -y --setopt=tsflags=nodocs install python3 python3-pip gnupg2 httpd-tools git openssh-clients && \
    dnf -y clean all --enablerepo='*'
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o /root/oc.tar.gz && \
    tar xvzf /root/oc.tar.gz -C /usr/local/bin
RUN pip3 install --upgrade --no-cache-dir pip setuptools wheel && \
    pip3 install --upgrade --no-cache-dir ansible openshift jmespath

# Handle requirements
RUN mkdir -p /app
COPY requirements.yml /app/requirements.yml
WORKDIR /app
RUN ansible-galaxy collection install -r requirements.yml

COPY ansible.cfg /app/ansible.cfg
COPY inventory /app/inventory
COPY playbooks /app/playbooks
COPY roles /app/roles

# You should bind-mount your own tmp and vars dirs for playbook persistence.

ENTRYPOINT ["ansible-playbook"]
CMD ["--help"]
