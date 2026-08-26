#!/usr/bin/env bash

which mitmproxy || uv tool install mitmproxy
which xray-knife || go install github.com/lilendian0x00/xray-knife/v11@latest
