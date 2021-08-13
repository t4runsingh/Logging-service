FROM node:12-alpine AS base
WORKDIR /usr/src/app


RUN apk update && apk add --no-cache bash
RUN  yarn install && yarn run build:ts
#RUN  yarn install && yarn run build:ts


COPY ./package.json yarn.lock ./
COPY lib/backend-commons-lib ./lib/backend-commons-lib
COPY lib/iam-utils ./lib/iam-utils
COPY logging-service/package.json logging-service/tsconfig.json ./logging-service/
COPY logging-service/docs ./logging-service/docs/

# Image for building and installing dependencies
# node-gyp is required as dependency by some npm package
# but node-gyp requires in build time python, build-essential, ....
# that's not required in runtime
FROM base AS dependencies
RUN apk update && apk add --no-cache \
    make \
    gcc \
    g++ \
    python
COPY logging-service ./logging-service
RUN  yarn install && yarn run build:ts

# FROM base AS release
# COPY --from=dependencies /usr/lib/app/logging-service/dist ./logging-service/dist
# COPY --from=dependencies /usr/lib/app/node_modules ./node_modules
# RUN rm yarn.lock

RUN chown -R node:node .
USER node

# WORKDIR /usr/src/app

# COPY package.json /usr/src/app

# RUN npm install --production

# COPY . /usr/src/app


CMD ["yarn", "start"]
