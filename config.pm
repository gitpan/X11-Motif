
# --------------------------------------------------------------------------------
# STEP 1:  Which modules do you want to build?
# --------------------------------------------------------------------------------
#
# NOTE: You must have working copies of the following software before
#       building the related modules.  The libraries are *not* distributed
#       with this package.  On some platforms, e.g. Linux, Motif is not a
#       standard option.  You may have to purchase it separately.  I have
#       reports that LessTif, the Motif freeware clone, works, but some
#       functionality is not yet implemented.

$want_motif = 1;	# build the Motif module?  1 = yes, 0 = no
$want_athena = 0;	# build the Athena module?  1 = yes, 0 = no
$want_xpm = 0;		# build the X Pixmap module?  1 = yes, 0 = no


# --------------------------------------------------------------------------------
# STEP 2:  How does your compiler work?
# --------------------------------------------------------------------------------

# How do you ask the compiler search for include files somewhere?
sub I_flag { "-I$_[0]" }				# generic

# How do you ask the linker search for libraries somewhere?
sub L_flag { "-L$_[0] -R$_[0]" }			# Solaris 2.5
#sub L_flag { "-L$_[0] -R$_[0]" }			# IRIX


# --------------------------------------------------------------------------------
# STEP 3:  Where is X installed?
# --------------------------------------------------------------------------------

# The directory that holds the X libraries (look for libX11.a)
$x_lib_dir = "/usr/openwin/lib";			# Solaris 2.5
#$x_lib_dir = "";					# IRIX

# The directory that holds the X includes (look for X11/Intrinsic.h)
$x_inc_dir = "/usr/openwin/include";			# Solaris 2.5
#$x_inc_dir = "";					# IRIX

# The X libraries needed on your platform:
$x_libs = "-lXext -lX11 -lgen -lsocket -lnsl";		# Solaris 2.5
#$x_libs = "-lXext -lX11";				# IRIX

# The X toolkit libraries needed on your platform:
$x_toolkit_libs = "-lXt -lXmu";				# generic


# --------------------------------------------------------------------------------
# STEP 4:  Where is Motif installed?
# --------------------------------------------------------------------------------
#
# NOTE: You only need to do this if you've set $want_motif = 1.

# The directory that holds the Motif libraries (look for libXm.a)
$motif_lib_dir = "/usr/dt/lib"; 			# Solaris 2.5
#$motif_lib_dir = "";					# IRIX

# The directory that holds the Motif includes (look for Xm/Xm.h)
$motif_inc_dir = "/usr/dt/include";			# Solaris 2.5
#$motif_inc_dir = "";					# IRIX

# The Motif libraries needed on your platform:
$motif_libs = "-lXm";					# generic


# --------------------------------------------------------------------------------
# STEP 5:  Where is Athena installed?
# --------------------------------------------------------------------------------
#
# NOTE: You only need to do this if you've set $want_athena = 1.

$athena_lib_dir = "/usr/openwin/lib";
$athena_inc_dir = "/usr/openwin/include";
$athena_libs = "-lXaw";


# --------------------------------------------------------------------------------
# STEP 6:  Where is X Pixmap installed?
# --------------------------------------------------------------------------------
#
# NOTE: You only need to do this if you've set $want_xpm = 1.

$xpm_lib_dir = "/ford/thishost/unix/div/ap/base/X11/lib";
$xpm_inc_dir = "/ford/thishost/unix/div/ap/base/X11/include";
$xpm_libs = "-lXpm";


# --------------------------------------------------------------------------------
# STEP 7:  Select additional compiler and/or linker flags.
# --------------------------------------------------------------------------------
#
# NOTE: You only need to do this if your standard Perl configuration
#       is not able to compile the modules.  The most common problem
#       occurs when the number of symbols exceeds the default limit.
#       You may have to change from -fpic to -fPIC for example.

@extra_MakeMaker_flags = ( 'CCCDLFLAGS' => '-fPIC' );	# gcc


# --------------------------------------------------------------------------------
# You shouldn't need to change anything more.
# --------------------------------------------------------------------------------

sub do_L_flag {
    my($dir) = @_;
    if ($dir !~ /^\s*$/) {
	return L_flag($dir);
    }
    "";
}

sub do_I_flag {
    my($dir) = @_;
    if ($dir !~ /^\s*$/) {
	return I_flag($dir);
    }
    "";
}

1;
