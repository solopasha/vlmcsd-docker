# Dockerized vlmcsd

Dockerized vlmcsd with hardened build flags && running under different user (not root)

## Usage

```shell
docker run -d -p 1688:1688 \
            --security-opt no-new-privileges \
            --restart=unless-stopped \
            --name vlmcsd \
            solopasha/vlmcsd
```
