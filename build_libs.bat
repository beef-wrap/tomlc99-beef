mkdir libs

clang -c -g -gcodeview -o tomlc99d.lib -target x86_64-pc-windows -fuse-ld=llvm-lib -Wall -Dtomlc99_IMPL tomlc99\toml.c
move tomlc99d.lib libs

clang -c -O3 -o tomlc99.lib -target x86_64-pc-windows -fuse-ld=llvm-lib -Wall -Dtomlc99_IMPL tomlc99\toml.c
move tomlc99.lib libs