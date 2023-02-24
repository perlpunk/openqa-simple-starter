package utils;

use base Exporter;
use Exporter;
use strict;
use testapi;
use File::Basename qw(basename);
use Time::HiRes qw/ sleep /;

our @EXPORT = qw(
    clear_root_console switch_to_x11 wait_for_desktop
    ensure_unlocked_desktop wait_for_container_log prepare_firefox_autoconfig
    demo_sleep
);

sub demo_sleep {
    my ($sec) = @_;
    return unless get_var('DEMO_MODE');
    sleep $sec;
}

sub clear_root_console {
    enter_cmd 'clear';
    enter_cmd 'cd';
    assert_screen 'root-console';
}

sub switch_to_x11 {
    my @hdd = split(/-/, basename get_required_var('HDD_1'));
    # older openSUSE Tumbleweed has x11 still on tty7
    my $x11_tty = $hdd[3] < 20190617 ? 'f7' : 'f2';
    send_key "ctrl-alt-$x11_tty";
}

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

# Waits until a text ($text) is found in the container logs.
# Controlled by a timeout (50s)
# Params:
# - $container: The container name or ID
# - $text: The text to search in the logs
# - $cmd: The containers runner (docker, podman,...)
# - $timeout: Time in seconds until this fails
#
sub wait_for_container_log {
    my ($container, $text, $cmd, $timeout) = @_;
    $timeout //= 50;
    while ($timeout > 0) {
        my $output = script_output("$cmd logs $container 2>&1");
        return if ($output =~ /$text/);
        $timeout--;
        sleep 1;
    }
    validate_script_output("$cmd logs $container 2>&1", qr/$text/);
}

# Use AutoConfig file for firefox to predefine some user values
# https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
sub prepare_firefox_autoconfig {
    # Enable AutoConfig by pointing to a cfg file
    type_string(q{cat <<EOF > $(rpm --eval %_libdir)/firefox/defaults/pref/autoconfig.js
pref("general.config.filename", "firefox.cfg");
pref("general.config.obscure_value", 0);
EOF
});
    # Create AutoConfig cfg file
    type_string(q{cat <<EOF > $(rpm --eval %_libdir)/firefox/firefox.cfg
// Mandatory comment
// https://firefox-source-docs.mozilla.org/browser/components/newtab/content-src/asrouter/docs/first-run.html
pref("browser.aboutwelcome.enabled", false);
pref("browser.startup.upgradeDialog.enabled", false);
pref("privacy.restrict3rdpartystorage.rollout.enabledByDefault", false);
EOF
});
}

1;