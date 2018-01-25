FROM node:9.4.0

WORKDIR /svc/cirrus-ci-docs
EXPOSE 8080

RUN npm install -g serve@6.4.9

ADD site/ /svc/cirrus-ci-docs/

CMD exec serve /svc/cirrus-ci-docs/ --port 8080
