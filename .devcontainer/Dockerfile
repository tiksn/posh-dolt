FROM mcr.microsoft.com/powershell:debian-10

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

RUN pwsh -c Install-Module -Name Pester -Force -AcceptLicense -Scope AllUsers
RUN curl -L https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash

ENV PoshDoltTestRepository="/home/$USERNAME/locales"
RUN dolt clone tiksn/locales ${PoshDoltTestRepository}
RUN chmod -R 777 ${PoshDoltTestRepository}
