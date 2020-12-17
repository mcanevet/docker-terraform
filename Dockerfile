FROM hashicorp/terraform:0.13.5 AS build-nss-wrapper

RUN apk add cmake gcc make musl-nscd-dev libc-dev curl-dev jansson-dev
RUN git clone git://git.samba.org/nss_wrapper.git
RUN cd nss_wrapper \
	&& git checkout nss_wrapper-1.1.11 \
	&& mkdir obj \
	&& cd obj \
	&& cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. \
	&& make
RUN find / -name libnss_wrapper.so

FROM hashicorp/terraform:0.13.5

RUN apk add jq gnupg

COPY --from=build-nss-wrapper /nss_wrapper/obj/src/libnss_wrapper.so /usr/local/lib/libnss_wrapper.so
