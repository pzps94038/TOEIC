# stage 1
FROM node:16 as node
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run build

FROM nginx:alpine
# 複製打包檔案，angular.json的outputPath
COPY --from=node /app/dist/toeic /usr/share/nginx/html
# 覆蓋image裡的設定檔
COPY /nginx.conf  /etc/nginx/conf.d/default.conf
EXPOSE 80
