## 使用hyperledger caliper 对hyperledger fabric进行基准测试

### 克隆samples仓库

```bash
$ git clone https://github.com/iamlzw/hyperledger-caliper-samples.git
$ cd hyperledger-caliper-samples
```

### 启动fabric网络

示例网络(fabric v1.4.2)包括两个peer组织，每个组织包括两个peer节点，一个orderer组织，包括一个orderer节点

```bash
$ cd hyperledger-caliper-samples
## 启动网络
$ ./start.sh
## 初始化网络，包括加入通道
## 输出当前项目路径,作为init.sh的参数
$ pwd
/home/www/go/src/github.com/hyperledger/fabric-samples/hyperledger-caliper-samples
$ ./init.sh /home/www/go/src/github.com/hyperledger/fabric-samples/hyperledger-caliper-samples
## 停止网络，当发生错误时，用于停止并清理网络
## ./stop.sh
```

### 克隆caliper-benchmarks仓库

```bash
$ cd hyperledger-caliper-samples
$ git clone https://github.com/hyperledger/caliper-benchmarks.git
```

### 安装caliper

参考[https://hyperledger.github.io/caliper/v0.4.2/installing-caliper/#installing-from-npm](https://hyperledger.github.io/caliper/v0.4.2/installing-caliper/#installing-from-npm)

```bash
$ cd hyperledger-caliper-samples/caliper-benchmarks
$ npm init -y
$ npm install --only=prod @hyperledger/caliper-cli@0.4.0
```

### 复制crypto-config目录以及channel-artifacts目录

方便在后面修改配置文件中的私钥以及证书路径

```bash
$ cd hyperledger-caliper-samples/
$ cp -r crypto-config caliper-benchmarks/
$ cp -r channel-artifacts caliper-benchmarks/
```

### 修改配置文件

这里需要修改fabric-go.yaml文件,基于```caliper-benchmarks/networks/fabric/v1/v1.4.1/2org1peergoleveldb/fabric-go-tls.yaml```进行修改,该文件的作用是用于连接测试网络,与sdk的配置文件类似,修改后的config.yaml文件位于hyperledger-caliper-samples/caliper-benchmarks目录下
```
$ cd hyperledger-caliper-samples/caliper-benchmarks/
$ vim fabric-go.yaml
```
添加以下内容

```yaml
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name: Fabric
version: "1.0"
mutual-tls: false

### 这里我们注释掉start 中的启动测试网络部分，因为测试网络已经启动
caliper:
  blockchain: fabric
  command:
    start: export FABRIC_VERSION=1.4;export FABRIC_CA_VERSION=1.4;sleep 3s
    #end: (test -z \"$(docker ps -aq)\") || docker rm $(docker ps -aq);(test -z \"$(docker images dev* -q)\") || docker rmi $(docker images dev* -q);rm -rf /tmp/hfc-*

info:
  Version: 1.4.2
  Size: 2 Orgs with 1 Peer
  Orderer: Solo,
  Distribution: Single Host
  StateDB: GoLevelDB

clients:
  client0.org1.example.com:
    client:
      organization: Org1
      credentialStore:
        path: /tmp/hfc-kvs/org1
        cryptoStore:
          path: /tmp/hfc-cvs/org1
      clientPrivateKey:
        path: crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore/c5dad79b0eb8ca81ce0078d204d3cc6872e5d64d64789c097dd2e30b2231ca6a_sk
      clientSignedCert:
        path: crypto-config/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem

  client0.org2.example.com:
    client:
      organization: Org2
      credentialStore:
        path: /tmp/hfc-kvs/org2
        cryptoStore:
          path: /tmp/hfc-cvs/org2
      clientPrivateKey:
        path: crypto-config/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp/keystore/c0ecca7ca5708c5b8a92c144ba53192a3f4b68a3c5ea45baf5f29d76c27836fa_sk
      clientSignedCert:
        path: crypto-config/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp/signcerts/User1@org2.example.com-cert.pem


channels:
  mychannel:
    configBinary: ./channel-artifacts/channel.tx
    ## 将created修改为true,因为通道已经创建
    created: true
    orderers:
    - orderer.example.com
    peers:
      peer0.org1.example.com:
        eventSource: true
      peer0.org2.example.com:
        eventSource: true

    contracts:
    - id: marbles
      version: v0
      language: golang
      path: fabric/samples/marbles/go
      metadataPath: src/fabric/samples/marbles/go/metadata
    - id: drm
      version: v0
      language: golang
      path: fabric/scenario/drm/go
    - id: simple
      version: v0
      language: golang
      path: fabric/scenario/simple/go
    - id: smallbank
      version: v0
      language: golang
      path: fabric/scenario/smallbank/go
organizations:
  Org1:
    mspid: Org1MSP
    peers:
    - peer0.org1.example.com
    adminPrivateKey:
      path: crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/9f7fcf72c99dca278e4af7f4fee5810db68ba3922af5aa4e0b30a5f4c95a3a3d_sk
    signedCert:
      path: crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem
  Org2:
    mspid: Org2MSP
    peers:
    - peer0.org2.example.com
    adminPrivateKey:
      path: crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/f530db1e8931f6901c3a362d93e86da87ec25d4e6fe884bc6575e840e219d92d_sk
    signedCert:
      path: crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/Admin@org2.example.com-cert.pem
orderers:
  orderer.example.com:
    url: grpcs://localhost:7050
    grpcOptions:
      ssl-target-name-override: orderer.example.com
    tlsCACerts:
      path: crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peers:
  peer0.org1.example.com:
    url: grpcs://localhost:7051
    grpcOptions:
      ssl-target-name-override: peer0.org1.example.com
      grpc.keepalive_time_ms: 600000
    tlsCACerts:
      path: crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
  peer0.org2.example.com:
    url: grpcs://localhost:9051
    grpcOptions:
      ssl-target-name-override: peer0.org2.example.com
      grpc.keepalive_time_ms: 600000
    tlsCACerts:
      path: crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem
```

### 测试

```bash
$ cd caliper-benchmarks/
$ npx caliper launch manager \
    --caliper-bind-sut fabric:1.4 \
    --caliper-workspace . \
    --caliper-benchconfig benchmarks/samples/fabric/marbles/config.yaml \
    --caliper-networkconfig fabric-go.yaml
```

![image.png](http://lifegoeson.cn:8888/images/2021/05/31/image.png)
可以在config.yaml中修改测试的参数

```bash
$ cd caliper-benchmarks/benchmarks/samples/fabric/marbles
$ vim config.yaml
```

```yaml
#### config.yaml
#### 通过修改txNumber,tps的值来修改测试参数,修改后停止并清理网络,之后进行新的测试即可。

test:
  workers:
    type: local
    number: 5
  rounds:
    - label: init
      txNumber: 500
      rateControl:
        type: fixed-rate
        opts:
          tps: 25
      workload:
        module: benchmarks/samples/fabric/marbles/init.js
    - label: query
      txDuration: 15
      rateControl:
        type: fixed-rate
        opts:
          tps: 5
      workload:
        module: benchmarks/samples/fabric/marbles/query.js
```



### 
### 问题及解决

Q: 执行```npx caliper bind --caliper-bind-sut fabric:1.4.0```时报错

```
error [caliper] [bind] 	Unknown "fabric" SDK version "1.4.0"
```

A:  执行```npx caliper bind --caliper-bind-sut fabric:1.4```,将1.4.0替换为1.4
