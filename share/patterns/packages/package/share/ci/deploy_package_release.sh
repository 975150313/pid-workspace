
#!/bin/bash
if [ "$PACKAGE_HAS_SITE" = true ] ; then
  cd build
  cmake --build . --target site -- synchro=true
  cd ..
fi
