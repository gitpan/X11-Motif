#!/ford/thishost/unix/div/ap/bin/perl

# Copyright 1997 by Ken Fox

use ExtUtils::MakeMaker;
require "../config.pm";

$libs = join(' ', do_L_flag($x_lib_dir), $x_toolkit_libs, $x_libs);
$incs = join(' ', '-I. -I../Lib', do_I_flag($x_inc_dir));

WriteMakefile('OPTIMIZE' => '-g',
	      'TYPEMAPS' => [ '../typemap' ],
	      'NAME' => 'X11::Toolkit',
	      'INC' => $incs,
	      'LIBS' => [ $libs ],
	      'OBJECT' => 'Toolkit.o ../Lib/packages.o',
	      'VERSION_FROM' => 'Toolkit.pm',
	      @extra_MakeMaker_flags);
