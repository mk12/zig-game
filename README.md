# Furious Fowls

TODO

clone with `--recursive` or run `git submodule update --init --recursive` after

## Usage

```
zig build
zig build -Drelease
zig build run
zig build test
zig fmt .

# macOS
env ZIG_SYSTEM_LINKER_HACK=1 zig build
# linux
zig build -Dtarget=x86_64-linux
# windows
zig build -Dtarget=x86_64-windows-gnu
```

## Dependencies

glfw (submodule)
    - cmake to build
zig

for cross compile to linux
`brew install libx11 libxcursor libxrandr libxinerama libxi`

## License

© 2021 Mitchell Kember

Furious Fowls is available under the MIT License; see [LICENSE](LICENSE.md) for details.
