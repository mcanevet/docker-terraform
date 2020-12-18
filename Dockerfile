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

ENV \
	GOPASS_VERSION=1.8.3 \
	SUMMON_VERSION=0.6.9 \
	TERRAFORM_PROVISIONER_ANSIBLE_VERSION=2.5.0

RUN apk add jq gnupg

# Install gopass
RUN wget https://github.com/gopasspw/gopass/releases/download/v${GOPASS_VERSION}/gopass-${GOPASS_VERSION}-linux-amd64.tar.gz -qO - | \
	tar xz gopass-${GOPASS_VERSION}-linux-amd64/gopass -O > /usr/local/bin/gopass
RUN chmod +x /usr/local/bin/gopass

# Install summon
RUN wget https://github.com/cyberark/summon/releases/download/v${SUMMON_VERSION}/summon-linux-amd64.tar.gz -qO - | \
	tar xz summon -O > /usr/local/bin/summon
RUN chmod +x /usr/local/bin/summon

# Install Terraform Ansible provisioner
RUN mkdir -p ~/.terraform.d/plugins \
	&& wget -q https://github.com/radekg/terraform-provisioner-ansible/releases/download/v${TERRAFORM_PROVISIONER_ANSIBLE_VERSION}/terraform-provisioner-ansible-linux-amd64_v${TERRAFORM_PROVISIONER_ANSIBLE_VERSION} -O ~/.terraform.d/plugins/terraform-provisioner-ansible_v${TERRAFORM_PROVISIONER_ANSIBLE_VERSION} \
	&& chmod +x ~/.terraform.d/plugins/terraform-provisioner-ansible_v${TERRAFORM_PROVISIONER_ANSIBLE_VERSION}

COPY --from=build-nss-wrapper /nss_wrapper/obj/src/libnss_wrapper.so /usr/local/lib/libnss_wrapper.so
COPY summon-gopass /usr/local/bin/summon-gopass
