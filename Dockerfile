FROM node:10

WORKDIR /svc/cirrus-ci-docs
EXPOSE 8080

RUN npm install -g serve@8.2.0
ADD serve.json /svc/cirrus-ci-docs/serve.json

ADD site/ /svc/cirrus-ci-docs/

CMD exec serve --listen 8080 \
               --config serve.json
