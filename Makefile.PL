#!/ford/thishost/unix/div/ap/bin/perl

# Copyright 1997 by Ken Fox

use ExtUtils::MakeMaker;
require "./config.pm";

WriteMakefile('OPTIMIZE' => '-g',
	      'PM' => { },
	      'NAME' => 'X11',
	      'DIR' => [ 'Lib', 'Toolkit', 'Motif' ]);
