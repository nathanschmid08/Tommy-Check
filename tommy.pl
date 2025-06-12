#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(sleep);

sub rgb {
    my ($r, $g, $b, $text) = @_;
    return "\e[38;2;${r};${g};${b}m$text\e[0m";
}

sub display_length {
    my $text = shift;
    $text =~ s/\e\[[0-9;]*m//g; 
    return length($text);
}

sub subtle_gradient {
    my ($text, $r1, $g1, $b1, $r2, $g2, $b2) = @_;
    my @chars = split //, $text;
    my $len = scalar @chars;
    return $text if $len <= 1;
    
    my $result = "";
    for my $i (0..$#chars) {
        my $ratio = $len > 1 ? $i / ($len - 1) : 0;
        my $r = int($r1 + ($r2 - $r1) * $ratio);
        my $g = int($g1 + ($g2 - $g1) * $ratio);
        my $b = int($b1 + ($b2 - $b1) * $ratio);
        $result .= rgb($r, $g, $b, $chars[$i]);
    }
    return $result;
}

sub hsv_to_rgb {
    my ($h, $s, $v) = @_;
    my $c = $v * $s;
    my $x = $c * (1 - abs(($h / 60) % 2 - 1));
    my $m = $v - $c;
    
    my ($r_prime, $g_prime, $b_prime);
    
    if ($h >= 0 && $h < 60) {
        ($r_prime, $g_prime, $b_prime) = ($c, $x, 0);
    } elsif ($h >= 60 && $h < 120) {
        ($r_prime, $g_prime, $b_prime) = ($x, $c, 0);
    } elsif ($h >= 120 && $h < 180) {
        ($r_prime, $g_prime, $b_prime) = (0, $c, $x);
    } elsif ($h >= 180 && $h < 240) {
        ($r_prime, $g_prime, $b_prime) = (0, $x, $c);
    } elsif ($h >= 240 && $h < 300) {
        ($r_prime, $g_prime, $b_prime) = ($x, 0, $c);
    } else {
        ($r_prime, $g_prime, $b_prime) = ($c, 0, $x);
    }
    
    return (int(($r_prime + $m) * 255), int(($g_prime + $m) * 255), int(($b_prime + $m) * 255));
}

sub gradient_text {
    my ($text, $r1, $g1, $b1, $r2, $g2, $b2) = @_;
    my @chars = split //, $text;
    my $len = scalar @chars;
    return $text if $len <= 1;
    
    my $result = "";
    for my $i (0..$#chars) {
        my $ratio = $len > 1 ? $i / ($len - 1) : 0;
        my $r = int($r1 + ($r2 - $r1) * $ratio);
        my $g = int($g1 + ($g2 - $g1) * $ratio);
        my $b = int($b1 + ($b2 - $b1) * $ratio);
        $result .= rgb($r, $g, $b, $chars[$i]);
    }
    return $result;
}

sub clear_screen {
    print "\e[2J\e[H";
}

my @nixie_art = (
' _______   _____    __  __   __  __  __     __    _O_   ',
'|__   __| / ___ \  |  \/  | |  \/  | \ \   / /  /     \\ ',
'   | |   | |   | | | \  / | | \  / |  \ \_/ /  |==/=\\==|',
'   | |   | |   | | | |\/| | | |\/| |   \   /   |  O O  |',
'   | |   | |   | | | |  | | | |  | |    | |     \\  V  / ',
'   | |   | |___| | | |  | | | |  | |    | |     /`---\'\\ ',
'   |_|    \ ___ /  |_|  |_| |_|  |_|    |_|     O\'_:_`O ',
'                                                 -- --   '
);

sub get_system_info {
    my %info;
    
    # Get RAM info (Linux/Unix)
    if (-r '/proc/meminfo') {
        my $meminfo = '/proc/meminfo';
        open my $fh, '<', $meminfo or die "Cannot open $meminfo: $!";
        
        while (<$fh>) {
            $info{total_ram} = int($1 / 1024) if /^MemTotal:\s+(\d+)/;
            $info{available_ram} = int($1 / 1024) if /^MemAvailable:\s+(\d+)/;
            $info{free_ram} = int($1 / 1024) if /^MemFree:\s+(\d+)/;
            $info{cached} = int($1 / 1024) if /^Cached:\s+(\d+)/;
            $info{buffers} = int($1 / 1024) if /^Buffers:\s+(\d+)/;
            $info{swap_total} = int($1 / 1024) if /^SwapTotal:\s+(\d+)/;
            $info{swap_free} = int($1 / 1024) if /^SwapFree:\s+(\d+)/;
        }
        close $fh;
        
        $info{used_ram} = $info{total_ram} - $info{available_ram};
        $info{ram_percent} = int(($info{used_ram} / $info{total_ram}) * 100);
        $info{swap_used} = $info{swap_total} - $info{swap_free};
        $info{swap_percent} = $info{swap_total} > 0 ? int(($info{swap_used} / $info{swap_total}) * 100) : 0;
    }
    
    # Get load average
    if (-r '/proc/loadavg') {
        open my $fh, '<', '/proc/loadavg';
        my $load_line = <$fh>;
        close $fh;
        ($info{load_1}, $info{load_5}, $info{load_15}) = split /\s+/, $load_line;
    }
    
    # Get uptime
    if (-r '/proc/uptime') {
        open my $fh, '<', '/proc/uptime';
        my $uptime_line = <$fh>;
        close $fh;
        my ($uptime_seconds) = split /\s+/, $uptime_line;
        my $days = int($uptime_seconds / 86400);
        my $hours = int(($uptime_seconds % 86400) / 3600);
        my $minutes = int(($uptime_seconds % 3600) / 60);
        $info{uptime} = sprintf("%dd %02dh %02dm", $days, $hours, $minutes);
    }
    
    # Get CPU info
    if (-r '/proc/cpuinfo') {
        open my $fh, '<', '/proc/cpuinfo';
        my $cpu_count = 0;
        my $cpu_model = "";
        while (<$fh>) {
            $cpu_count++ if /^processor\s*:/;
            $cpu_model = $1 if /^model name\s*:\s*(.+)$/ && !$cpu_model;
        }
        close $fh;
        $info{cpu_count} = $cpu_count;
        $info{cpu_model} = $cpu_model;
        $info{cpu_model} =~ s/\s+/ /g if $info{cpu_model};  # Clean up spaces
    }
    
    # Get disk usage for root filesystem
    my $df_output = `df -h / 2>/dev/null`;
    if ($df_output && $df_output =~ /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)%\s+\/$/) {
        $info{disk_total} = $2;
        $info{disk_used} = $3;
        $info{disk_available} = $4;
        $info{disk_percent} = $5;
    }
    
    # Get network interfaces
    if (-r '/proc/net/dev') {
        open my $fh, '<', '/proc/net/dev';
        my @interfaces;
        while (<$fh>) {
            next if /^\s*(Inter-|face|lo:)/;  # Skip header and loopback
            if (/^\s*(\w+):/) {
                push @interfaces, $1;
            }
        }
        close $fh;
        $info{network_interfaces} = \@interfaces;
    }
    
    return %info;
}

# Progress bar function
sub draw_progress_bar {
    my ($percent, $width, $filled_char, $empty_char) = @_;
    $width //= 40;
    $filled_char //= '█';
    $empty_char //= '░';
    
    my $filled = int($percent * $width / 100);
    my $empty = $width - $filled;
    
    my $bar = '';
    
    # Color coding based on percentage
    my ($r, $g, $b);
    if ($percent < 50) {
        ($r, $g, $b) = (0, 255, 0);  # Green
    } elsif ($percent < 75) {
        ($r, $g, $b) = (255, 255, 0);  # Yellow
    } elsif ($percent < 90) {
        ($r, $g, $b) = (255, 165, 0);  # Orange
    } else {
        ($r, $g, $b) = (255, 0, 0);    # Red
    }
    
    $bar .= rgb($r, $g, $b, $filled_char x $filled);
    $bar .= rgb(100, 100, 100, $empty_char x $empty);
    
    return "[$bar]";
}

# Helper function for proper box line formatting
sub format_box_line {
    my ($content, $width) = @_;
    $width //= 76;
    
    my $content_length = display_length($content);
    my $padding = $width - $content_length;
    $padding = 0 if $padding < 0;
    
    return "│ $content" . " " x $padding . " │\n";
}

# Main display function
sub display_system_status {
    clear_screen();
    
    # Get system information
    my %info = get_system_info();
    
    # MEMORY STATUS BOX
    if (exists $info{ram_percent}) {
        print "╭" . "─" x 78 . "╮\n";
        print format_box_line(rgb(100, 200, 255, "MEMORY STATUS"));
        print "├" . "─" x 78 . "┤\n";
        
        my $ram_bar = draw_progress_bar($info{ram_percent});
        my $usage_text = sprintf("Usage: %3d%% ", $info{ram_percent});
        print format_box_line($usage_text . $ram_bar);
        
        my $used_line = sprintf("Used: %dMB    Available: %dMB", $info{used_ram}, $info{available_ram});
        print format_box_line(rgb(150, 150, 150, $used_line));
        
        my $total_line = sprintf("Total: %dMB    Cached: %dMB    Buffers: %dMB", 
                               $info{total_ram}, $info{cached} || 0, $info{buffers} || 0);
        print format_box_line(rgb(150, 150, 150, $total_line));
        
        # Status message with appropriate colors
        my $status_msg;
        my $status_color;
        if ($info{ram_percent} < 50) {
            $status_msg = "Status: Alles im gruenen Bereich";
            $status_color = [0, 255, 0];
        } elsif ($info{ram_percent} < 75) {
            $status_msg = "Status: Schon etwas voll, aber ok";
            $status_color = [255, 255, 0];
        } elsif ($info{ram_percent} < 90) {
            $status_msg = "Status: Hoher Speicherverbrauch";
            $status_color = [255, 165, 0];
        } else {
            $status_msg = "Status: RAM fast voll";
            $status_color = [255, 0, 0];
        }
        
        print format_box_line(rgb($status_color->[0], $status_color->[1], $status_color->[2], $status_msg));
        print "╰" . "─" x 78 . "╯\n";
    }
    
    # SWAP STATUS BOX
    if (exists $info{swap_total} && $info{swap_total} > 0) {
        print "\n";
        print "╭" . "─" x 78 . "╮\n";
        print format_box_line(rgb(255, 150, 100, "SWAP STATUS"));
        print "├" . "─" x 78 . "┤\n";
        
        my $swap_bar = draw_progress_bar($info{swap_percent});
        my $swap_usage_text = sprintf("Usage: %3d%% ", $info{swap_percent});
        print format_box_line($swap_usage_text . $swap_bar);
        
        my $swap_line = sprintf("Used: %dMB    Free: %dMB    Total: %dMB", 
                              $info{swap_used}, $info{swap_free}, $info{swap_total});
        print format_box_line(rgb(150, 150, 150, $swap_line));
        print "╰" . "─" x 78 . "╯\n";
    }
    
    # CPU INFORMATION BOX
    if (exists $info{cpu_model}) {
        print "\n";
        print "╭" . "─" x 78 . "╮\n";
        print format_box_line(rgb(100, 255, 150, "CPU INFORMATION"));
        print "├" . "─" x 78 . "┤\n";
        
        my $cpu_line = sprintf("Cores: %d", $info{cpu_count});
        print format_box_line(rgb(200, 200, 200, $cpu_line));
        
        # Truncate CPU model if too long
        my $cpu_model = $info{cpu_model};
        if (length($cpu_model) > 70) {
            $cpu_model = substr($cpu_model, 0, 67) . "...";
        }
        print format_box_line(rgb(200, 200, 200, "Model: $cpu_model"));
        print "╰" . "─" x 78 . "╯\n";
    }
    
    # SYSTEM LOAD BOX
    if (exists $info{load_1}) {
        print "\n";
        print "╭" . "─" x 78 . "╮\n";
        print format_box_line(rgb(255, 200, 100, "SYSTEM LOAD"));
        print "├" . "─" x 78 . "┤\n";
        
        my $load_line = sprintf("Load Average: %.2f, %.2f, %.2f (1m, 5m, 15m)", 
                              $info{load_1}, $info{load_5}, $info{load_15});
        print format_box_line(rgb(200, 200, 200, $load_line));
        
        if (exists $info{uptime}) {
            my $uptime_line = sprintf("Uptime: %s", $info{uptime});
            print format_box_line(rgb(200, 200, 200, $uptime_line));
        }
        print "╰" . "─" x 78 . "╯\n";
    }
    
    # DISK USAGE BOX
    if (exists $info{disk_percent}) {
        print "\n";
        print "╭" . "─" x 78 . "╮\n";
        print format_box_line(rgb(255, 100, 200, "DISK USAGE (Root Filesystem)"));
        print "├" . "─" x 78 . "┤\n";
        
        my $disk_bar = draw_progress_bar($info{disk_percent});
        my $disk_usage_text = sprintf("Usage: %3d%% ", $info{disk_percent});
        print format_box_line($disk_usage_text . $disk_bar);
        
        my $disk_line = sprintf("Used: %s    Available: %s    Total: %s", 
                              $info{disk_used}, $info{disk_available}, $info{disk_total});
        print format_box_line(rgb(150, 150, 150, $disk_line));
        print "╰" . "─" x 78 . "╯\n";
    }
    
    # NETWORK INTERFACES BOX
    if (exists $info{network_interfaces} && @{$info{network_interfaces}}) {
        print "\n";
        print "╭" . "─" x 78 . "╮\n";
        print format_box_line(rgb(150, 255, 200, "NETWORK INTERFACES"));
        print "├" . "─" x 78 . "┤\n";
        
        my $interfaces_text = "Active: " . join(", ", @{$info{network_interfaces}});
        if (length($interfaces_text) > 70) {
            $interfaces_text = substr($interfaces_text, 0, 67) . "...";
        }
        print format_box_line(rgb(200, 200, 200, $interfaces_text));
        print "╰" . "─" x 78 . "╯\n";
    }
    
    # Timestamp without gradient - clean and simple
    my $timestamp = scalar localtime;
    print "\n" . rgb(180, 180, 180, "Last updated: $timestamp") . "\n";
    
    # Display Nixie ASCII art above credit line - clean without gradient
    print "\n";
    foreach my $line (@nixie_art) {
        print rgb(150, 200, 255, $line) . "\n";
    }
    
    # Credit line - clean without gradient
    print "\n" . rgb(200, 150, 255, "Tommy Check v2.0 by Nixie") . "\n";
}

# Main execution
sub main {
    # Check if we should run in continuous mode
    my $continuous = @ARGV && $ARGV[0] eq '--continuous';
    
    if ($continuous) {
        print rgb(100, 255, 100, "Starting Tommy Check in continuous mode... Press Ctrl+C to exit\n");
        sleep(2);
        
        while (1) {
            display_system_status();
            sleep(5);  # Update every 5 seconds
        }
    } else {
        display_system_status();
        print "\n" . rgb(200, 200, 200, "Tipp: Starte mit --continuous fuer Live-Monitoring\n");
    }
}

# Run the program
main();