#!/bin/sh
cd rel
../rebar create-node nodeid=cheea
cd ..
./rebar generate
