FROM alpine:3.12

RUN apk update \
  && apk add --no-cache gcc libc-dev python3 py3-pip python3-dev \
  && pip3 install --upgrade pip \
  && pip3 install mkdocs mkdocs-material plantuml-markdown python-markdown-math pygments pymdown-extensions

RUN pip3 install python-markdown-math mkdocs-awesome-pages-plugin mkdocs-autolinks-plugin

RUN mkdir -p /root/projects