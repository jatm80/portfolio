FROM node:12.14.1-alpine3.9 as sdk

# run build using:  docker build --force-rm --build-arg VUE_BUILD_MODE=stg -t test:0.1 .
#default environment config is stg
#override by using --build-arg VUE_BUILD_MODE=prod
ARG VUE_BUILD_MODE=stg

# Add source for compiling
ADD ./src /src
WORKDIR /src

# Start compiling
RUN echo $VUE_BUILD_MODE
RUN npm install
RUN npm run "$VUE_BUILD_MODE"
RUN ls -ls dist

FROM nginx:1.16.1-alpine

EXPOSE 80

ADD nginx.conf /etc/nginx/nginx.conf
RUN mkdir /wwwroot


#Copy the compiled stuff to /wwwroot
COPY --from=sdk /src/dist /wwwroot

ENTRYPOINT [ "nginx" , "-g", "daemon off;"]