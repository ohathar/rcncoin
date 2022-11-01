#!/bin/bash

rcncoind -daemon
tail -F /dev/null
