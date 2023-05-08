FROM node:18-alpine AS builder
WORKDIR /web/
COPY package.json .
RUN --mount=type=cache,target=/root/.npm npm install
COPY . .
RUN npm install && npm run build

FROM nginx:1.21.6-alpine
WORKDIR /root/
COPY --from=builder /web/dist ./static/
COPY nginx.conf /etc/nginx/nginx.conf
