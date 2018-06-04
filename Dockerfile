FROM node:10

WORKDIR /svc/cirrus-ci-docs
EXPOSE 8080

RUN npm install -g serve@6.5.8

ADD site/ /svc/cirrus-ci-docs/

CMD exec serve /svc/cirrus-ci-docs/ --port 8080
