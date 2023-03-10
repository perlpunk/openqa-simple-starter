use strict;
use warnings;
use base "basetest";
use testapi;
use utils qw(ensure_unlocked_desktop );
use Time::HiRes qw/ sleep /;

sub run {
    ensure_unlocked_desktop;
    demosleep 2;
    x11_start_program("gnome-clocks", 60, {valid => 1});

    assert_screen 'clock-started-click-stopwatch', 10;
    demosleep 1;

    assert_and_click 'clock-started-click-stopwatch', timeout => 10;

    assert_and_click 'stopwatch', timeout => 10;
    demosleep 1;

    assert_screen 'stopwatch-running', 10;
    sleep 3;
    assert_and_click 'stopwatch-running', timeout => 10;
    demosleep 2;

    assert_and_click 'stopwatch-running-added-lap', timeout => 10;

    assert_screen 'stopwatch-paused', 10;
    demosleep 3;
    assert_and_click 'stopwatch-paused', timeout => 10;
    demosleep 1;

    return;
}

sub test_flags {
    return {fatal => 1};
}

1;
