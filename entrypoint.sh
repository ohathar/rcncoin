#!/bin/bash

rcncoind -daemon -reindex
tail -F /dev/null
