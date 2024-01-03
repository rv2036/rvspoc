FROM milkvtech/milkv-duo:latest

RUN echo "Asia/Shanghai" >/etc/timezone

RUN apt update && \
	apt upgrade -y && \
	apt install -y \
		tmux \
		zsh \
		zsh-autosuggestions \
		zsh-syntax-highlighting \
		locales && \
	apt clean all && \
	apt autoremove && \
	locale-gen en_US.UTF-8

ENV TERM=xterm-256color
ENV LANG=en_US.UTF-8

RUN  mkdir -p /home/worker
COPY dot-zshrc /root/.zshrc

WORKDIR /home/worker
CMD ["/bin/zsh", "-l"]
