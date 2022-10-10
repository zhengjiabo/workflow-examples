FROM node:16-alpine as builder
ARG COMMIT_REF_NAME

# 单独分离 package.json，是为了 npm 可最大限度利用缓存
ADD package.json package-lock.json /code/
WORKDIR /code/
RUN npm install

# 单独分离打包文件，是为了避免 ADD . /code 时，因为 Readme/nginx.conf 的更改避免缓存生效
# 为了 yarn build 可最大限度利用缓存
ADD public /code/public/
ADD src /code/src/
ADD index.html env.d.ts vite.config.ts /code/
RUN npx vite build --base /$COMMIT_REF_NAME


# 选择更小体积的基础镜像
FROM nginx:alpine
ADD nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /code/dist /usr/share/nginx/html
ENV HOST 0.0.0.0 
EXPOSE 80