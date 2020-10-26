# This docker file extends node to support pulling packages from bitbucket

FROM node:12.16.2

RUN groupadd -g 1001 -o jenkins
RUN useradd -m -u 1001 -g 1001 -o -s /bin/bash jenkins

USER jenkins

RUN npm config set registry http://npm-registry.demo.local/
RUN mkdir -p /home/jenkins/workspace
RUN chown -R jenkins /home/jenkins/workspace
WORKDIR /home/jenkins/workspace

ENTRYPOINT [ "/usr/local/bin/npm" ]