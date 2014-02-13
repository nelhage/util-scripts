#!/usr/bin/env perl
use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

=head1 DESCRIPTION

=cut

my $confdir = $ENV{HOME} . "/.crondiff";
unless($ENV{USER}) {
    chomp(my $user = `id -un`);
    $ENV{USER} = $user;
};
my $mailto = $ENV{USER} . '@mit.edu';
my @mailer = qw(mutt -x);

my $cachedir = "$confdir/cache";

mkdir("$cachedir") unless -e "$cachedir";

open(my $clist, "<", "$confdir/cmdlist")
  or exit;

while(my $cmd = <$clist>) {
    chomp($cmd);
    my $hash = md5_hex($cmd);
    my $pid = fork;
    if($pid == 0) {
        # Child
        close(STDOUT);
        close(STDERR);
        open(STDOUT, ">>", "$cachedir/$hash.new");
        open(STDERR, ">>", "$cachedir/$hash.new");
        exec("/bin/bash", "-c", $cmd);
    }
    waitpid($pid, 0);
    if($? != 0) {
        # Exited with error, should send mail, but punting for now.
        unlink("$cachedir/$hash");
        unlink("$cachedir/$hash.new");
        next;
    } elsif(-f "$cachedir/$hash"
       && system("diff -q $cachedir/$hash.new $cachedir/$hash > /dev/null 2>&1") != 0) {
        # Output changed
        if(($pid = fork) == 0) {
            close(STDOUT);
            open(STDOUT, "|-", @mailer, $mailto, '-s', "Output of [$cmd]");
            system("date");
            print "----\n";
            system("diff", "-u", "-U", "0", "$cachedir/$hash", "$cachedir/$hash.new");
            exit;
        } else {
            waitpid($pid, 0);
        }
    }
    rename("$cachedir/$hash.new", "$cachedir/$hash");
}
