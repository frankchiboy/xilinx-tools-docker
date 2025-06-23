FROM ubuntu:jammy
ENV DEBIAN_FRONTEND=noninteractive

# Install packages required for running the vivado installer and X11 GUI
RUN \
  ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    libtinfo5 \
    locales \
    lsb-release \
    net-tools \
    patch \
    unzip \
    wget \
    libx11-6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxrandr2 \
    libxss1 \
    libxinerama1 \
    libxcursor1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libgtk-3-0 \
    libasound2 \
    && \
  apt-get autoclean && \
  apt-get autoremove && \
  locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8 && \
  rm -rf /var/lib/apt/lists/*

# 安裝 Vivado 2020.2 需要的 32/64 bit 相依套件，避免安裝程式誤判平台
RUN apt-get update -y && \
    dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
      libc6:i386 \
      libncurses5:i386 \
      libstdc++6:i386 \
      lib32z1 \
      libbz2-1.0:i386 && \
    rm -rf /var/lib/apt/lists/*

# Set up the base address for where installer binaries are stored within ESnet's private network
#
# NOTE: This URL is NOT REACHABLE outside of ESnet's private network.  Non-ESnet users must follow
#       the instructions in the README.md file and download their own copies of the installers
#       directly from the AMD/Xilinx website and drop them into the vivado-installer directory
#
ARG DISPENSE_BASE_URL="https://dispense.es.net/Linux/xilinx"

# Install the Xilinx Vivado tools and updates in headless mode
# ENV var to help users to find the version of vivado that has been installed in this container
ENV VIVADO_BASE_VERSION=2020.2
ENV VIVADO_VERSION=${VIVADO_BASE_VERSION}
# Xilinx installer tar file originally from: https://www.xilinx.com/support/download.html
ARG VIVADO_INSTALLER="Xilinx_Unified_${VIVADO_VERSION}_1118_1232.tar.gz"
ARG VIVADO_UPDATE=""
# Installer config file
ARG VIVADO_INSTALLER_CONFIG="/vivado-installer/install_config_vivado.${VIVADO_VERSION}.txt"

COPY vivado-installer/ /vivado-installer/
RUN \
  mkdir -p /vivado-installer/install && \
  ( \
    if [ -e /vivado-installer/$VIVADO_INSTALLER ] ; then \
      tar xf /vivado-installer/$VIVADO_INSTALLER --strip-components=1 -C /vivado-installer/install ; \
    else \
      wget -qO- $DISPENSE_BASE_URL/$VIVADO_INSTALLER | tar x --strip-components=1 -C /vivado-installer/install ; \
    fi \
  ) && \
  if [ ! -e ${VIVADO_INSTALLER_CONFIG} ] ; then \
    /vivado-installer/install/xsetup \
      -p 'Vivado' \
      -e 'Vivado HL WebPACK' \
      -b ConfigGen && \
    echo "No installer configuration file was provided.  Generating a default one for you to modify." && \
    echo "-------------" && \
    cat /root/.Xilinx/install_config.txt && \
    echo "-------------" && \
    exit 1 ; \
  fi ; \
  /vivado-installer/install/xsetup \
    -a XilinxEULA,3rdPartyEULA,WebTalkTerms \
    --batch Install \
    --config ${VIVADO_INSTALLER_CONFIG} && \
  rm -r /vivado-installer/install && \
  mkdir -p /vivado-installer/update && \
  if [ ! -z "$VIVADO_UPDATE" ] ; then \
    ( \
      if [ -e /vivado-installer/$VIVADO_UPDATE ] ; then \
        tar xf /vivado-installer/$VIVADO_UPDATE --strip-components=1 -C /vivado-installer/update ; \
      else \
        wget -qO- $DISPENSE_BASE_URL/$VIVADO_UPDATE | tar x --strip-components=1 -C /vivado-installer/update ; \
      fi \
    ) && \
    /vivado-installer/update/xsetup \
      -a XilinxEULA,3rdPartyEULA,WebTalkTerms \
      --batch Update \
      --config ${VIVADO_INSTALLER_CONFIG} && \
    rm -r /vivado-installer/update ; \
  fi && \
  rm -rf /vivado-installer

# ONLY REQUIRED FOR Ubuntu 20.04 (focal) but harmless on other distros
# Hack: replace the stock libudev1 with a newer one from Ubuntu 22.04 (jammy) to avoid segfaults when invoked
#       from the flexlm license code within Vivado
RUN \
  if [ "$(lsb_release --short --release)" = "20.04" ] ; then \
    wget -q -P /tmp http://linux.mirrors.es.net/ubuntu/pool/main/s/systemd/libudev1_249.11-0ubuntu3_amd64.deb && \
    dpkg-deb --fsys-tarfile /tmp/libudev1_*.deb | \
      tar -C /tools/Xilinx/${VIVADO_BASE_VERSION}/Vivado/lib/lnx64.o/Ubuntu/20 --strip-components=4 -xavf - ./usr/lib/x86_64-linux-gnu/ && \
    rm /tmp/libudev1_*.deb ; \
  fi

# Add the Xilinx tools directory to the system path
ENV PATH="/tools/Xilinx/${VIVADO_BASE_VERSION}/Vivado/bin:${PATH}"

# Set up the entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
