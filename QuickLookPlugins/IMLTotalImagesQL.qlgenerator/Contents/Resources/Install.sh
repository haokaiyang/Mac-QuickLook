#!/bin/sh

#  Install.sh
#  Image Size
#
#  Created by Le Anh Tung on 5/19/15.
#  Copyright (c) 2015 © IML. All rights reserved.

PRODUCT="${PRODUCT_NAME}.qlgenerator"
QL_PATH=~/Library/QuickLook/

rm -rf "$QL_PATH/$PRODUCT"
test -d "$QL_PATH" || mkdir -p "$QL_PATH" && cp -R "$BUILT_PRODUCTS_DIR/$PRODUCT" "$QL_PATH"
qlmanage -r

echo "$PRODUCT installed in $QL_PATH"