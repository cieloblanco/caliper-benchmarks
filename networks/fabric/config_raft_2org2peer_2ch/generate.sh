#!/usr/bin/env bash

: "${FABRIC_VERSION:=1.4.1}"
: "${FABRIC_CA_VERSION:=1.4.1}"

# if the binaries are not available, download them
if [[ ! -d "bin" ]]; then
  curl -sSL http://bit.ly/2ysbOFE | bash -s -- ${FABRIC_VERSION} ${FABRIC_CA_VERSION} 0.4.14 -ds
fi

rm -rf ./crypto-config/
rm -f ./genesis.block
rm -f ./mychannel.tx

./bin/cryptogen generate --config=./crypto-config.yaml

./bin/configtxgen -profile OrdererGenesis -outputBlock genesis.block -channelID syschannel

./bin/configtxgen -profile ChannelOrg1Config -outputCreateChannelTx channel-org1.tx -channelID channel-org1

./bin/configtxgen -profile ChannelOrg2Config -outputCreateChannelTx channel-org2.tx -channelID channel-org2


# Rename the key files we use to be key.pem instead of a uuid
for KEY in $(find crypto-config -type f -name "*_sk"); do
    KEY_DIR=$(dirname ${KEY})
    mv ${KEY} ${KEY_DIR}/key.pem
done
