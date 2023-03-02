package utils;
use strict;
use warnings;

use base 'Exporter';
use testapi;
use Time::HiRes qw/ sleep /;

our @EXPORT = qw(
    wait_for_desktop ensure_unlocked_desktop
);

sub wait_for_desktop {
    assert_screen([qw/boot-menu openqa-desktop/]);
    if (match_has_tag('boot-menu')) {
        send_key 'ret';
    }
    assert_screen 'openqa-desktop', 500;
    if (match_has_tag('openqa-desktop-locked')) {
        send_key 'esc';
        wait_still_screen(1);
        type_string $testapi::password . "\n";
        assert_screen 'openqa-desktop';
    }
    elsif (match_has_tag('openqa-desktop-login')) {
        assert_and_click 'openqa-desktop-login';
        wait_still_screen(1);
        type_string $testapi::password . "\n";
        assert_screen 'openqa-desktop';
    }
}


# if stay under tty console for long time, then check
# screen lock is necessary when switch back to x11
# all possible options should be handled within loop to get unlocked desktop
sub ensure_unlocked_desktop {
    my $counter = 10;
    while ($counter--) {
        assert_screen [qw(displaymanager displaymanager-password-prompt generic-desktop screenlock gnome-screenlock-password)], no_wait => 1;
        if (match_has_tag 'displaymanager') {
            if (check_var('DESKTOP', 'minimalx')) {
                type_string "$username";
                save_screenshot;
            }
            send_key 'ret';
        }
        if ((match_has_tag 'displaymanager-password-prompt') || (match_has_tag 'gnome-screenlock-password')) {
            type_password;
            send_key 'ret';
        }
        if (match_has_tag 'generic-desktop') {
            send_key 'esc';
            last;    # desktop is unlocked, mission accomplished
        }
        if (match_has_tag 'screenlock') {
            wait_screen_change {
                send_key 'esc';    # end screenlock
            };
        }
        wait_still_screen 2;                                                                              # slow down loop
        die 'ensure_unlocked_desktop repeated too much. Check for X-server crash.' if ($counter eq 1);    # die loop when generic-desktop not matched
    }
}

1;
