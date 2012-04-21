#!/bin/sh
erl -sname cheea -pa ebin -pa deps/*/ebin \
	-boot start_sasl -s cheea