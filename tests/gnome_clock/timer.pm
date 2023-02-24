use strict;
use warnings;
use base "basetest";
use testapi;
use utils qw(ensure_unlocked_desktop demo_sleep);
use Time::HiRes qw/ sleep /;

sub run {
    ensure_unlocked_desktop;
    demo_sleep 2;
    x11_start_program("gnome-clocks", 60, {valid => 1});

    assert_screen 'clock-started-click-timer', 10;
    demo_sleep 1;

    assert_and_click 'clock-started-click-timer', timeout => 10, clicktime => 1;

    assert_and_click 'new-timer-menu', timeout => 10, dlick => 1;
    demo_sleep 1;

    send_key 'delete';
    demo_sleep 1;
    type_string '10';
    demo_sleep 1;
    send_key 'tab';

    assert_and_click 'new-timer-menu-selected-10s', timeout => 10;

    demo_sleep 2;
    assert_screen 'timer-running', 10;
    demo_sleep 2;
    assert_and_click 'timer-finished', timeout => 10;

    return;
}

sub test_flags {
    return {fatal => 1};
}

1;
