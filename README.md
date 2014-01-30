sandbox-share
=============

share cabal sandbox

Usage
-------------
```
cd $SANDBOXDIR
mkdir yesod
cd yesod
cabal sandbox init
cabal install yesod-platform yesod-bin
export PATH=$PATH:`pwd`/.cabal-sandbox/bin

cd $PROJECTROOT
yesod init
cd $PROJECTNAME
cabal sandbox init
sandbox-share $SANDBOXDIR/yesod
cabal install --enable-tests .
yesod devel
```
