FROM node:18-alpine AS builder
WORKDIR /web/
COPY package.json .
RUN --mount=type=cache,target=/root/.npm npm install
COPY . .
RUN npm install && npm run build

FROM builder AS test

FROM nginx:1.21.6-alpine AS prod
WORKDIR /root/
COPY ./htpasswd /etc/nginx/htpasswd
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /web/dist ./static/
