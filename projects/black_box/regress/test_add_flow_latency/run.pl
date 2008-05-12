#!/usr/bin/perl -w
# test_add_flow_bandwidth

use strict;
use IO::Socket;
use Data::HexDump;
use Data::Dumper;

use NF2::TestLib;
use NF2::PacketLib;
use OF::OFUtil;
use OF::OFPacketLib;

use strict;

use Time::HiRes qw(sleep gettimeofday tv_interval usleep);

sub my_test {

	my ($sock) = @_;

	my $pkt_args = {
	    DA => "00:00:00:00:00:01",
	    SA => "00:00:00:00:00:02",
	    src_ip => "192.168.0.40",
	    dst_ip => "192.168.1.40",
	    ttl => 64,
	    len => 60
	};

	my $test_pkt = new NF2::UDP_pkt(%$pkt_args);

	## ip_hdr_len is not correctly set by NF2 lib, so do it here.
	my $iphdr=$test_pkt->{'IP_hdr'};
	$$iphdr->ip_hdr_len(5); #set ip_hdr_len




	my $wildcards = 0x0;
	my $in_port = 1;
	my $out_port = 2;

	my $flow_mod_pkt = create_flow_mod_from_udp($ofp,$test_pkt,$in_port,$out_port,0,0);

	print $sock $flow_mod_pkt;
	usleep(1000000);


	my $cnt = 0;
	my $start_time = [gettimeofday()];
	my %delta;
	for( $cnt = 0;$cnt < 1000; $cnt++){
	    nftest_send( nftest_get_iface( "eth" . ($in_port+1)),$test_pkt->packed );
	    nftest_expect( nftest_get_iface( "eth" . ($out_port+1)),$test_pkt->packed );
	}			
	my $time_elapse = tv_interval($start_time);
	my $latency = $time_elapse*1000/1000;
	print "Latency is $latency ms";

    }


run_black_box_test( \&my_test);
