#!/bin/bash

case "$OSTYPE" in
  darwin*)  OS="darwin" ;;
  linux*)   OS="linux" ;;
esac

cd /tmp

curl -s https://api.github.com/repos/kubeflow/kfctl/releases/latest \
| grep "browser_download_url.*kfctl.*$OS.*\.tar\.gz" \
| cut -d ":" -f 2,3 \
| tr -d \" \
| wget -qi -

tarball="$(find . -name "*kfctl*$OS*.tar.gz" 2>/dev/null)"
tar -xzf $tarball

chmod +x kfctl
mv kfctl /usr/local/bin/

rm -f $tarball
cd - &>/dev/null

echo "Installed kfctl version:"
kfctl version