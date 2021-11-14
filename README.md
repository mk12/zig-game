# Zig game

WIP game in Zig.

Was using bgfx at first, now Sokol instead.

<!-- clone with `--recursive` or run `git submodule update --init --recursive` after -->
./deps.sh to install glfw, bgfx

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

glfw
bgfx (and bx)
zig

for cross compile to linux
`brew install libx11 libxcursor libxrandr libxinerama libxi`
or on linux itself
`sudo apt-get install xorg-dev`

## License

© 2021 Mitchell Kember

Furious Fowls is available under the MIT License; see [LICENSE](LICENSE.md) for details.
