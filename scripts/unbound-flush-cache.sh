#!/bin/bash
set -e

/usr/sbin/unbound-control flush .
/usr/sbin/unbound-control flush zone .
/usr/sbin/unbound-control flush_infra all
