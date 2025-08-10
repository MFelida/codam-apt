#!/bin/bash

CAPT_DIR="${HOME}/sgoinfre/.capt"
echo "Creating directories..."
mkdir -p ${CAPT_DIR}/root
mkdir -p ${CAPT_DIR}/debs_temp

echo "Creating installer script..."
cat <<"EOF" >${CAPT_DIR}/capt
#!/bin/bash

cd ${CAPT_DIR}/debs_temp
rm -rf *.deb
if [[ $1 == "install" ]]; then
	echo "Downloading prerequisites..."
	apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $2 | grep "^\w" | sort -u)
	echo "Installing..."
	find . -iname "*.deb" -type f -exec dpkg -x {} ${CAPT_DIR}/root \;
	echo "Finished installing, removing temp files..."
	rm -rf *.deb
	echo "Done"
else
	echo "Capt only supports \`capt install\`"
fi

EOF

echo "Setting executable bit on \`capt\` executable..."
chmod +x ${CAPT_DIR}/capt

echo "Adding stuff to zshrc"
cat <<EOF >>${HOME}/.zshrc
export LD_LIBRARY_PATH=${CAPT_DIR}/root/lib/x86_64-linux-gnu:${CAPT_DIR}/root/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export PATH=${CAPT_DIR}:${CAPT_DIR}/root/usr/local/sbin:${CAPT_DIR}/root/usr/local/bin:${CAPT_DIR}/root/usr/sbin:${CAPT_DIR}/root/usr/bin:${CAPT_DIR}/root/sbin:${CAPT_DIR}/root/bin:${CAPT_DIR}/root/usr/games:${CAPT_DIR}/root/usr/local/games:${CAPT_DIR}/snap/bin:$PATH

EOF

echo "Adding stuff to bashrc"
cat <<EOF >>${HOME}/.bashrc
export LD_LIBRARY_PATH=${CAPT_DIR}/root/lib/x86_64-linux-gnu:${CAPT_DIR}/root/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export PATH=${CAPT_DIR}:${CAPT_DIR}/root/usr/local/sbin:${CAPT_DIR}/root/usr/local/bin:${CAPT_DIR}/root/usr/sbin:${CAPT_DIR}/root/usr/bin:${CAPT_DIR}/root/sbin:${CAPT_DIR}/root/bin:${CAPT_DIR}/root/usr/games:${CAPT_DIR}/root/usr/local/games:${CAPT_DIR}/snap/bin:$PATH

EOF

FISHRC=${HOME}/.config/fish/config.fish
if [ -f $FISHRC ]; then
	echo "Adding stuff to fishrc"
	cat <<EOF >>$FISHRC

# add capt to PATH

set -p LD_LIBRARY_PATH ${CAPT_DIR}/root/lib/x86_64-linux-gnu:${CAPT_DIR}/root/usr/lib/x86_64-linux-gnu
set -p PATH ${CAPT_DIR}:${CAPT_DIR}/root/bin:${CAPT_DIR}/root/sbin:${CAPT_DIR}/root/usr/bin:${CAPT_DIR}/root/usr/sbin:${CAPT_DIR}/root/usr/games:${CAPT_DIR}/root/usr/local/bin:${CAPT_DIR}/root/usr/local/sbin:${CAPT_DIR}/root/usr/local/games:${CAPT_DIR}/snap/bin
EOF
fi

echo "Done, please restart your shell or run \`source ${HOME}/.zshrc\` / \`source ${HOME}/.bashrc\` / \'source ${HOME}/.config/fish/config.fish\' (depending on your shell)"
