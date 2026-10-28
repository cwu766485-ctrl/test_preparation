# Counter modes

This directory contains three counters with distinct wrap behavior:

- `cnt_up`: increments while `en` is high. With `WIDTH=4`, it counts 0 through 15, then wraps to 0.
- `cnt_down`: decrements while `en` is high. With `WIDTH=4`, it counts 0, 15, 14, ..., then wraps from 0 to 15.
- `cnt_modN`: increments while `en` is high and wraps from `N-1` to 0. For `N=10`, its sequence is 0 through 9. This differs from a 4-bit up-counter, which continues through 15.

All three use an active-low asynchronous reset. `cnt_modN.tc` is high whenever the current count equals `N-1`, including while the counter is disabled.

## Run the VCS tests

From this directory in Linux/WSL with VCS available:

```sh
make          # compile and run all three self-checking testbenches
make test_cnt_up
make test_cnt_down
make test_cnt_modN
make clean    # remove generated build files
```
