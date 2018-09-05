#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;

use strict;
use X11::Motif;
use X11::Xpm;

print "Using X11::Motif version $X11::Motif::VERSION.\n";
print "This is beta #", X11::Motif::beta_version(), "\n" if (X11::Motif::beta_version());

my $toplevel = X::Toolkit::initialize("Example",
					-colors => -max,
					-colormap => -readonly);

print "initialized Xt\n";

my $display = $toplevel->XtDisplay;

my $folder = give $toplevel -Folder;
my $stack = X::Toolkit::search_from_parent($folder, 'stack');

my $form1 = give $stack -Form, -layerName => 'Weird';
my $form2 = give $stack -Form, -layerName => 'Demo';
my $form3 = give $stack -Form, -layerName => 'Stuff';

my $menubar = give $form1 -MenuBar;
my $menu;
my $submenu;

$menu = give $menubar -Menu, -name => 'File';
	give $menu -Toggle, -text => 'Ok?';
	$submenu = give $menu -Menu, -text => 'More...';
		   give $submenu -Button, -text => 'Red', -foreground => 'red';
		   give $submenu -Button, -text => 'White', -foreground => 'white';
		   give $submenu -Button, -text => 'Blue', -foreground => 'blue';
	give $menu -Separator;
	give $menu -Button, -text => 'Quit', -command => sub { exit 0 };

$menu = give $menubar -Menu, -name => 'Edit';
	give $menu -Button, -text => 'Cut';
	give $menu -Button, -text => 'Paste';

$menu = give $menubar -Menu, -name => 'Help';
	give $menu -Button, -text => 'Help!';

my $subform = give $form1 -Form;

my $hello = give $subform -Label,
		-background => 'yellow',
		-font => '-*-helvetica-bold-r-*-*-*-240-*-*-*-*-*-*',
		-text => 'Hello, world!';

my $quit = give $subform -Button,
		-command => sub { exit };

#my($icon, $mask) = X::Xpm::CreatePixmap($toplevel, -file => 'data/quit.xpm');
my($icon, $mask) = X::Xpm::CreatePixmap($toplevel, -data => <<"EOF");
32 32 3 1 
  c None
. c black
X c red
          ............          
         .            .         
        . XXXXXXXXXXXX .        
       . XXXXXXXXXXXXXX .       
      . XXXXXXXXXXXXXXXX .      
     . XXXXXXXXXXXXXXXXXX .     
    . XXXXXXXXXXXXXXXXXXXX .    
   . XXXXXXXXXXXXXXXXXXXXXX .   
  . XXXXXXXXXXXXXXXXXXXXXXXX .  
 . XXXXXXXXXXXXXXXXXXXXXXXXXX . 
. XXX   XX     XX   XX    XXXX .
. XX XXX XXX XXX XXX X XXX XXX .
. XX XXXXXXX XXX XXX X XXX XXX .
. XX XXXXXXX XXX XXX X XXX XXX .
. XXX XXXXXX XXX XXX X XXX XXX .
. XXXX XXXXX XXX XXX X    XXXX .
. XXXXX XXXX XXX XXX X XXXXXXX .
. XXXXXX XXX XXX XXX X XXXXXXX .
. XXXXXX XXX XXX XXX X XXXXXXX .
. XXXXXX XXX XXX XXX X XXXXXXX .
. XX XXX XXX XXX XXX X XXXXXXX .
. XXX   XXXX XXXX   XX XXXXXXX .
 . XXXXXXXXXXXXXXXXXXXXXXXXXX . 
  . XXXXXXXXXXXXXXXXXXXXXXXX .  
   . XXXXXXXXXXXXXXXXXXXXXX .   
    . XXXXXXXXXXXXXXXXXXXX .    
     . XXXXXXXXXXXXXXXXXX .     
      . XXXXXXXXXXXXXXXX .      
       . XXXXXXXXXXXXXX .       
        . XXXXXXXXXXXX .        
         .            .         
          ............          
EOF

if (defined $icon) {
    change $quit -icon => $icon;
}
else {
    change $quit -text => 'Quit';
}

my $toggle = give $subform -Toggle,
		-text => 'Are you bored?';

my $cursor;

sub do_Show {
    my($widget, $client, $call) = @_;

    if ($client) {
	print "client data = $client\n";
    }

    my $userData = query $widget -userData;

    print "user data = $userData\n";
    if (ref($userData) eq 'ARRAY') {
	print "user data[0] = $userData->[0]\n";
	print "user data[1] = $userData->[1]\n";
	print "user data[2] = $userData->[2]\n";
    }

    if ($call) {
	print "call data = $call\n";
	print "  reason = ", $call->reason(), "\n";
	print "       X = ", $call->event->x(), "\n";
	print "       Y = ", $call->event->y(), "\n";
    }

    my @v = query $widget 'x', 'y', 'managed', 'topAttachment', 'bottomAttachment', 'labelString', 'name', 'mnemonicCharSet';
    print "widget values = ", join(', ', @v), "\n";
    print "label string = ", $v[5]->plain(), "\n";

    if (query $quit -managed) {
	change $quit -managed => X::False;
	change $widget -text => 'show';

	if (!$cursor) {
	    $cursor = X::CreateFontCursor($toplevel->Display, 150);
	}

	X::DefineCursor($toplevel->Display, $toplevel->Window, $cursor);
    }
    else {
	change $quit -managed => X::True;
	change $widget -text => 'hide';

	X::UndefineCursor($toplevel->Display, $toplevel->Window);
    }
}

my $hide = give $subform -Button,
		-text => 'hide',
		-userData => [ $subform, 'testing', 1, 2, 3 ],
		-command => [\&do_Show, 10];

#arrange $subform -fill => 'xy', -top => $hello, -left => [ $quit, $hide ];
#arrange $subform -fill => 'x',  -top => $hello, -left => [ $quit, $hide ];
#arrange $subform                -top => $hello, -left => [ $quit, $hide ];

#arrange $subform -fill => 'xy', -bottom => $hello, -left => [ $quit, $hide ];
#arrange $subform -fill => 'x',  -bottom => $hello, -fill => 'none', -left => [ $quit, $hide ];
#arrange $subform                -bottom => $hello, -left => [ $quit, $hide ];

#arrange $subform -fill => 'xy', -left => [ $quit, $hide ], -bottom => $hello;
#arrange $subform -fill => 'x',  -left => [ $quit, $hide ], -bottom => $hello;
#arrange $subform                -left => [ $quit, $hide ], -bottom => $hello;

#arrange $subform -fill => 'y',  -left => [ $quit, $hide ], -fill => 'x', -bottom => $hello;

my @fill_sides = ( -right => -form, -left => -form );

change $subform -fractionBase => 4;
constrain $hello  -top => -form, -bottom => 1, @fill_sides;
constrain $quit   -top => 1, -bottom => 2, @fill_sides;
constrain $toggle -top => 2, -bottom => 3, @fill_sides;
constrain $hide   -top => 3, -bottom => -form, @fill_sides;

arrange $form1 -fill => 'xy', -top => [ $menubar, $subform ];

handle $toplevel;
