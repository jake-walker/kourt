#!/bin/bash
sed -i '' "s;MARKETING_VERSION = .*;MARKETING_VERSION = ${CZ_PRE_NEW_VERSION};g" Skip.env
