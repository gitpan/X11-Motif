#!/ford/thishost/unix/div/ap/bin/perl

# Copyright 1997 by Ken Fox

use ExtUtils::MakeMaker;
require "../config.pm";

$libs = join(' ', do_L_flag($motif_lib_dir), do_L_flag($x_lib_dir),
	     $motif_libs, $x_toolkit_libs, $x_libs);

$incs = join(' ', '-I. -I../Lib -I../Toolkit',
	     do_I_flag($motif_inc_dir), do_I_flag($x_inc_dir));

if ($want_motif) {
    WriteMakefile('OPTIMIZE' => '-g',
		  'TYPEMAPS' => [ '../typemap' ],
		  'NAME' => 'X11::Motif',
		  'INC' => $incs,
		  'LIBS' => [ $libs ],
		  'OBJECT' => 'Motif.o ../Lib/packages.o ../Toolkit/Toolkit.o Grid.o Stack.o Folder.o',
		  'VERSION_FROM' => 'Motif.pm',
		  @extra_MakeMaker_flags);
}
