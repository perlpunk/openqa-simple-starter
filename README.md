os-autoinst/openQA test example
===============================

Tests for gnome-clock using openQA. Needs the corresponding [needle
repository](https://github.com/perlpunk/openqa-simple-starter-needles)

For more details see the [openQA project](http://open.qa/)

## Demo Video

This video shows how a test run looks like when called with te below job settings:
* [video-gnome-clock.ogv](https://github.com/perlpunk/openqa-simple-starter/blob/videos/video-gnome-clock.ogv)

## Usage

To run this test, you can clone a recent job from the [openQA job
group](https://openqa.opensuse.org/group_overview/24) and simply replace
the test code with this repository:

```
openqa-clone-job \
    --host localhost:9526 --skip-chained-deps https://openqa.opensuse.org/tests/3069790 \
    GROUP=0 _GROUP=0 BUILD= TEST=gnome-clock \
    PRODUCTDIR=/path/to/openqa-simple-starter \
    NEEDLES_DIR=/path/to/openqa-simple-starter-needles \
    CASEDIR=/path/to/openqa-simple-starter \
    DEMO_MODE=1 SCREENSHOTINTERVAL=0.1
```

## Requirements

For running openQA, see [openQA project](http://open.qa/).

For this specific test code you would need the [draft
PR](https://github.com/os-autoinst/os-autoinst/pull/2274) adding `DEMO_MODE`
functions.

