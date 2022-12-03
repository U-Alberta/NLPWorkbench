FROM node:18-alpine AS builder
WORKDIR /web/
COPY package.json .
RUN --mount=type=cache,target=/root/.npm npm install
COPY . .
RUN npm install && npm run build

FROM node:18-alpine AS sncBuilder
WORKDIR /web/
COPY snc/package.json .
RUN --mount=type=cache,target=/root/.npm npm install
COPY snc .
RUN npm run build

FROM nginx:1.21.6-alpine
WORKDIR /root/
COPY --from=builder /web/dist ./static/
COPY --from=sncBuilder /web/build ./static/snc
COPY nginx.conf /etc/nginx/nginx.conf
