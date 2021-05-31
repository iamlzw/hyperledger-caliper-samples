#!/bin/sh
#export env

export PATH=/home/www/go/src/github.com/hyperledger/fabric-samples/bin:$PATH
export FABRIC_CFG_PATH=/home/www/go/src/github.com/hyperledger/fabric-samples/config/

export CORE_PEER_TLS_ENABLED=true

export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051


#create channel
peer channel create -o orderer.example.com:7050 -c mychannel -f channel-artifacts/channel.tx --tls --cafile /home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

#peer0.org1 join channel
peer channel join -b mychannel.block

# export peer0.org2 env
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051

#peer0.org2 join channel
peer channel join -b mychannel.block

#export peer0.org1 env
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

#install chaincode on peer0.org1
peer chaincode install -n fabcar -v 1.0 -p chaincode/fabcar/go

# export peer0.org2 env
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:9051


#install chaincode on peer0.org2
peer chaincode install -n fabcar -v 1.0 -p chaincode/fabcar/go

#export peer0.org1 env
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

#instantiate chaincode on peer0.org1
peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar -v 1.0 -c '{"Args":["initLedger"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"

sleep 10s

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /home/www/go/src/github.com/hyperledger/fabric-samples/my-network/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["initLedger"]}'

