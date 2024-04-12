#!/usr/bin/env bash

cd docs/api/
ldoc -c gremlin.ldoc .
ldoc -c evac.ldoc .
ldoc -c urgency.ldoc .
ldoc -c waves.ldoc .

cd ../../
mdbook build
