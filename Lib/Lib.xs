
/* Copyright 1997 by Ken Fox */

#define NEEDS_PIXEL

#include "x-api.h"


MODULE = X11::Lib		PACKAGE = X

PROTOTYPES: ENABLE


SV *
is_integer(sv)
	SV *			sv
	CODE:
	    RETVAL = (SvIOK(sv)) ? &sv_yes : &sv_no;
	OUTPUT:
	    RETVAL

SV *
is_real(sv)
	SV *			sv
	CODE:
	    RETVAL = (SvNOK(sv)) ? &sv_yes : &sv_no;
	OUTPUT:
	    RETVAL

SV *
is_string(sv)
	SV *			sv
	CODE:
	    RETVAL = (SvPOK(sv)) ? &sv_yes : &sv_no;
	OUTPUT:
	    RETVAL

SV *
is_object(sv)
	SV *			sv
	CODE:
	    RETVAL = (SvROK(sv) && SvOBJECT(SvRV(sv))) ? &sv_yes : &sv_no;
	OUTPUT:
	    RETVAL

double
display_width_pixels_per_mm(display, screen_id = -1)
	Display *		display
	int			screen_id
	CODE:
	    if (screen_id == -1) screen_id = DefaultScreen(display);
	    RETVAL = DisplayWidth(display, screen_id) / DisplayWidthMM(display, screen_id);
	OUTPUT:
	    RETVAL

double
display_height_pixels_per_mm(display, screen_id = -1)
	Display *		display
	int			screen_id
	CODE:
	    if (screen_id == -1) screen_id = DefaultScreen(display);
	    RETVAL = DisplayHeight(display, screen_id) / DisplayHeightMM(display, screen_id);
	OUTPUT:
	    RETVAL

double
screen_width_pixels_per_mm(screen)
	Screen *		screen
	CODE:
	    RETVAL = WidthOfScreen(screen) / WidthMMOfScreen(screen);
	OUTPUT:
	    RETVAL

double
screen_height_pixels_per_mm(screen)
	Screen *		screen
	CODE:
	    RETVAL = HeightOfScreen(screen) / HeightMMOfScreen(screen);
	OUTPUT:
	    RETVAL


# ----------------------------------------------------------------------
# The next section was derived from an automatically generated XS
# template.

# -- BEGIN list-raw-funs OUTPUT --
int
XActivateScreenSaver(display)
	Display *		display

int
XAddHost(display, host)
	Display *		display
	XHostAddress *		host

int
XAddHosts(display, hosts, num_hosts)
	Display *		display
	XHostAddress *		hosts
	int			num_hosts

int
XAddToSaveSet(display, w)
	Display *		display
	Window			w

unsigned long
XAllPlanes()


XClassHint *
XAllocClassHint()


int
XAllocColor(display, colormap, screen_in_out)
	Display *		display
	Colormap		colormap
	XColor *		screen_in_out

int
XAllocColorCells(display, colormap, contig, plane_masks_return, nplanes, pixels_return, npixels)
	Display *		display
	Colormap		colormap
	int			contig
	unsigned long *		plane_masks_return
	unsigned int		nplanes
	unsigned long *		pixels_return
	unsigned int		npixels

int
XAllocColorPlanes(display, colormap, contig, pixels_return, ncolors, nreds, ngreens, nblues, rmask_return, gmask_return, bmask_return)
	Display *		display
	Colormap		colormap
	int			contig
	unsigned long *		pixels_return
	int			ncolors
	int			nreds
	int			ngreens
	int			nblues
	unsigned long *		rmask_return
	unsigned long *		gmask_return
	unsigned long *		bmask_return

XIconSize *
XAllocIconSize()


int
XAllocNamedColor(display, colormap, color_name, screen_def_return, exact_def_return)
	Display *		display
	Colormap		colormap
	char *			color_name
	XColor *		screen_def_return
	XColor *		exact_def_return

XSizeHints *
XAllocSizeHints()


XStandardColormap *
XAllocStandardColormap()


XWMHints *
XAllocWMHints()


int
XAllowEvents(display, event_mode, time)
	Display *		display
	int			event_mode
	Time			time

int
XAutoRepeatOff(display)
	Display *		display

int
XAutoRepeatOn(display)
	Display *		display

char *
XBaseFontNameListOfFontSet(font_set)
	XFontSet		font_set

int
XBell(display, percent)
	Display *		display
	int			percent

int
XBitmapBitOrder(display)
	Display *		display

int
XBitmapPad(display)
	Display *		display

int
XBitmapUnit(display)
	Display *		display

unsigned long
XBlackPixel(display, screen_number)
	Display *		display
	int			screen_number

unsigned long
XBlackPixelOfScreen(screen)
	Screen *		screen

int
XCellsOfScreen(screen)
	Screen *		screen

int
XChangeActivePointerGrab(display, event_mask, cursor, time)
	Display *		display
	unsigned int		event_mask
	Cursor			cursor
	Time			time

int
XChangeGC(display, gc, valuemask, values)
	Display *		display
	GC			gc
	unsigned long		valuemask
	XGCValues *		values

int
XChangeKeyboardControl(display, value_mask, values)
	Display *		display
	unsigned long		value_mask
	XKeyboardControl *	values

int
XChangeKeyboardMapping(display, first_keycode, keysyms_per_keycode, keysyms, num_codes)
	Display *		display
	int			first_keycode
	int			keysyms_per_keycode
	KeySym *		keysyms
	int			num_codes

int
XChangePointerControl(display, do_accel, do_threshold, accel_numerator, accel_denominator, threshold)
	Display *		display
	int			do_accel
	int			do_threshold
	int			accel_numerator
	int			accel_denominator
	int			threshold

int
XChangeProperty(display, w, property, type, format, mode, data, nelements)
	Display *		display
	Window			w
	Atom			property
	Atom			type
	int			format
	int			mode
	unsigned char *		data
	int			nelements

int
XChangeSaveSet(display, w, change_mode)
	Display *		display
	Window			w
	int			change_mode

int
XChangeWindowAttributes(display, w, valuemask, attributes)
	Display *		display
	Window			w
	unsigned long		valuemask
	XSetWindowAttributes *	attributes

int
XCheckMaskEvent(display, event_mask, event_return)
	Display *		display
	long			event_mask
	XEvent *		event_return

int
XCheckTypedEvent(display, event_type, event_return)
	Display *		display
	int			event_type
	XEvent *		event_return

int
XCheckTypedWindowEvent(display, w, event_type, event_return)
	Display *		display
	Window			w
	int			event_type
	XEvent *		event_return

int
XCheckWindowEvent(display, w, event_mask, event_return)
	Display *		display
	Window			w
	long			event_mask
	XEvent *		event_return

int
XCirculateSubwindows(display, w, direction)
	Display *		display
	Window			w
	int			direction

int
XCirculateSubwindowsDown(display, w)
	Display *		display
	Window			w

int
XCirculateSubwindowsUp(display, w)
	Display *		display
	Window			w

int
XClearArea(display, w, x, y, width, height, exposures)
	Display *		display
	Window			w
	int			x
	int			y
	unsigned int		width
	unsigned int		height
	int			exposures

int
XClearWindow(display, w)
	Display *		display
	Window			w

int
XClipBox(r, rect_return)
	Region			r
	XRectangle *		rect_return

int
XCloseDisplay(display)
	Display *		display

int
XConfigureWindow(display, w, value_mask, values)
	Display *		display
	Window			w
	unsigned int		value_mask
	XWindowChanges *	values

int
XConnectionNumber(display)
	Display *		display

int
XContextDependentDrawing(font_set)
	XFontSet		font_set

int
XConvertSelection(display, selection, target, property, requestor, time)
	Display *		display
	Atom			selection
	Atom			target
	Atom			property
	Window			requestor
	Time			time

int
XCopyArea(display, src, dest, gc, src_x, src_y, width, height, dest_x, dest_y)
	Display *		display
	Drawable		src
	Drawable		dest
	GC			gc
	int			src_x
	int			src_y
	unsigned int		width
	unsigned int		height
	int			dest_x
	int			dest_y

Colormap
XCopyColormapAndFree(display, colormap)
	Display *		display
	Colormap		colormap

int
XCopyGC(display, src, valuemask, dest)
	Display *		display
	GC			src
	unsigned long		valuemask
	GC			dest

int
XCopyPlane(display, src, dest, gc, src_x, src_y, width, height, dest_x, dest_y, plane)
	Display *		display
	Drawable		src
	Drawable		dest
	GC			gc
	int			src_x
	int			src_y
	unsigned int		width
	unsigned int		height
	int			dest_x
	int			dest_y
	unsigned long		plane

Pixmap
XCreateBitmapFromData(display, d, data, width, height)
	Display *		display
	Drawable		d
	char *			data
	unsigned int		width
	unsigned int		height

Colormap
XCreateColormap(display, w, visual, alloc)
	Display *		display
	Window			w
	Visual *		visual
	int			alloc

Cursor
XCreateFontCursor(display, shape)
	Display *		display
	unsigned int		shape

XFontSet
XCreateFontSet(display, base_font_name_list, missing_charset_list, missing_charset_count, def_string)
	Display *		display
	char *			base_font_name_list
	char ***		missing_charset_list
	int *			missing_charset_count
	char **			def_string

GC
XCreateGC(display, d, valuemask, values)
	Display *		display
	Drawable		d
	unsigned long		valuemask
	XGCValues *		values

Cursor
XCreateGlyphCursor(display, source_font, mask_font, source_char, mask_char, foreground_color, background_color)
	Display *		display
	Font			source_font
	Font			mask_font
	unsigned int		source_char
	unsigned int		mask_char
	XColor *		foreground_color
	XColor *		background_color

XImage *
XCreateImage(display, visual, depth, format, offset, data, width, height, bitmap_pad, bytes_per_line)
	Display *		display
	Visual *		visual
	unsigned int		depth
	int			format
	int			offset
	char *			data
	unsigned int		width
	unsigned int		height
	int			bitmap_pad
	int			bytes_per_line

Pixmap
XCreatePixmap(display, d, width, height, depth)
	Display *		display
	Drawable		d
	unsigned int		width
	unsigned int		height
	unsigned int		depth

Cursor
XCreatePixmapCursor(display, source, mask, foreground_color, background_color, x, y)
	Display *		display
	Pixmap			source
	Pixmap			mask
	XColor *		foreground_color
	XColor *		background_color
	unsigned int		x
	unsigned int		y

Pixmap
XCreatePixmapFromBitmapData(display, d, data, width, height, fg, bg, depth)
	Display *		display
	Drawable		d
	char *			data
	unsigned int		width
	unsigned int		height
	unsigned long		fg
	unsigned long		bg
	unsigned int		depth

Region
XCreateRegion()


Window
XCreateSimpleWindow(display, parent, x, y, width, height, border_width, border, background)
	Display *		display
	Window			parent
	int			x
	int			y
	unsigned int		width
	unsigned int		height
	unsigned int		border_width
	unsigned long		border
	unsigned long		background

Window
XCreateWindow(display, parent, x, y, width, height, border_width, depth, class, visual, valuemask, attributes)
	Display *		display
	Window			parent
	int			x
	int			y
	unsigned int		width
	unsigned int		height
	unsigned int		border_width
	int			depth
	unsigned int		class
	Visual *		visual
	unsigned long		valuemask
	XSetWindowAttributes *	attributes

Colormap
XDefaultColormap(display, screen_number)
	Display *		display
	int			screen_number

Colormap
XDefaultColormapOfScreen(screen)
	Screen *		screen

int
XDefaultDepth(display, screen_number)
	Display *		display
	int			screen_number

int
XDefaultDepthOfScreen(screen)
	Screen *		screen

GC
XDefaultGC(display, screen_number)
	Display *		display
	int			screen_number

GC
XDefaultGCOfScreen(screen)
	Screen *		screen

Window
XDefaultRootWindow(display)
	Display *		display

int
XDefaultScreen(display)
	Display *		display

Screen *
XDefaultScreenOfDisplay(display)
	Display *		display

char *
XDefaultString()


Visual *
XDefaultVisual(display, screen_number)
	Display *		display
	int			screen_number

Visual *
XDefaultVisualOfScreen(screen)
	Screen *		screen

int
XDefineCursor(display, w, cursor)
	Display *		display
	Window			w
	Cursor			cursor

int
XDeleteContext(display, rid, context)
	Display *		display
	XID			rid
	XContext		context

XModifierKeymap *
XDeleteModifiermapEntry(modmap, keycode_entry, modifier)
	XModifierKeymap *	modmap
	unsigned int		keycode_entry
	int			modifier

int
XDeleteProperty(display, w, property)
	Display *		display
	Window			w
	Atom			property

int
XDestroyRegion(r)
	Region			r

int
XDestroySubwindows(display, w)
	Display *		display
	Window			w

int
XDestroyWindow(display, w)
	Display *		display
	Window			w

int
XDisableAccessControl(display)
	Display *		display

int
XDisplayCells(display, screen_number)
	Display *		display
	int			screen_number

int
XDisplayHeight(display, screen_number)
	Display *		display
	int			screen_number

int
XDisplayHeightMM(display, screen_number)
	Display *		display
	int			screen_number

int
XDisplayKeycodes(display, min_keycodes_return, max_keycodes_return)
	Display *		display
	int *			min_keycodes_return
	int *			max_keycodes_return

unsigned long
XDisplayMotionBufferSize(display)
	Display *		display

char *
XDisplayName(string)
	char *			string

Display *
XDisplayOfScreen(screen)
	Screen *		screen

int
XDisplayPlanes(display, screen_number)
	Display *		display
	int			screen_number

char *
XDisplayString(display)
	Display *		display

int
XDisplayWidth(display, screen_number)
	Display *		display
	int			screen_number

int
XDisplayWidthMM(display, screen_number)
	Display *		display
	int			screen_number

int
XDoesBackingStore(screen)
	Screen *		screen

int
XDoesSaveUnders(screen)
	Screen *		screen

int
XDrawArc(display, d, gc, x, y, width, height, angle1, angle2)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	unsigned int		width
	unsigned int		height
	int			angle1
	int			angle2

int
XDrawArcs(display, d, gc, arcs, narcs)
	Display *		display
	Drawable		d
	GC			gc
	XArc *			arcs
	int			narcs

int
XDrawImageString(display, d, gc, x, y, string, length)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	char *			string
	int			length

int
XDrawImageString16(display, d, gc, x, y, string, length)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	XChar2b *		string
	int			length

int
XDrawLine(display, d, gc, x1, y1, x2, y2)
	Display *		display
	Drawable		d
	GC			gc
	int			x1
	int			y1
	int			x2
	int			y2

int
XDrawLines(display, d, gc, points, npoints, mode)
	Display *		display
	Drawable		d
	GC			gc
	XPoint *		points
	int			npoints
	int			mode

int
XDrawPoint(display, d, gc, x, y)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y

int
XDrawPoints(display, d, gc, points, npoints, mode)
	Display *		display
	Drawable		d
	GC			gc
	XPoint *		points
	int			npoints
	int			mode

int
XDrawRectangle(display, d, gc, x, y, width, height)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	unsigned int		width
	unsigned int		height

int
XDrawRectangles(display, d, gc, rectangles, nrectangles)
	Display *		display
	Drawable		d
	GC			gc
	XRectangle *		rectangles
	int			nrectangles

int
XDrawSegments(display, d, gc, segments, nsegments)
	Display *		display
	Drawable		d
	GC			gc
	XSegment *		segments
	int			nsegments

int
XDrawString(display, d, gc, x, y, string, length)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	char *			string
	int			length

int
XDrawString16(display, d, gc, x, y, string, length)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	XChar2b *		string
	int			length

int
XDrawText(display, d, gc, x, y, items, nitems)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	XTextItem *		items
	int			nitems

int
XDrawText16(display, d, gc, x, y, items, nitems)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	XTextItem16 *		items
	int			nitems

int
XEmptyRegion(r)
	Region			r

int
XEnableAccessControl(display)
	Display *		display

int
XEqualRegion(r1, r2)
	Region			r1
	Region			r2

long
XEventMaskOfScreen(screen)
	Screen *		screen

int
XEventsQueued(display, mode)
	Display *		display
	int			mode

long
XExtendedMaxRequestSize(display)
	Display *		display

XFontSetExtents *
XExtentsOfFontSet(font_set)
	XFontSet		font_set

char *
XFetchBuffer(display, nbytes_return, buffer)
	Display *		display
	int *			nbytes_return
	int			buffer

char *
XFetchBytes(display, nbytes_return)
	Display *		display
	int *			nbytes_return

int
XFetchName(display, w, window_name_return)
	Display *		display
	Window			w
	char **			window_name_return

int
XFillArc(display, d, gc, x, y, width, height, angle1, angle2)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	unsigned int		width
	unsigned int		height
	int			angle1
	int			angle2

int
XFillArcs(display, d, gc, arcs, narcs)
	Display *		display
	Drawable		d
	GC			gc
	XArc *			arcs
	int			narcs

int
XFillPolygon(display, d, gc, points, npoints, shape, mode)
	Display *		display
	Drawable		d
	GC			gc
	XPoint *		points
	int			npoints
	int			shape
	int			mode

int
XFillRectangle(display, d, gc, x, y, width, height)
	Display *		display
	Drawable		d
	GC			gc
	int			x
	int			y
	unsigned int		width
	unsigned int		height

int
XFillRectangles(display, d, gc, rectangles, nrectangles)
	Display *		display
	Drawable		d
	GC			gc
	XRectangle *		rectangles
	int			nrectangles

int
XFilterEvent(event, window)
	XEvent *		event
	Window			window

int
XFindContext(display, rid, context, data_return)
	Display *		display
	XID			rid
	XContext		context
	XPointer *		data_return

int
XFlush(display)
	Display *		display

void
XFlushGC(display, gc)
	Display *		display
	GC			gc

int
XFontsOfFontSet(font_set, font_struct_list, font_name_list)
	XFontSet		font_set
	XFontStruct ***		font_struct_list
	char ***		font_name_list

int
XForceScreenSaver(display, mode)
	Display *		display
	int			mode

GContext
XGContextFromGC(gc)
	GC			gc

int
XGeometry(display, screen, position, default_position, bwidth, fwidth, fheight, xadder, yadder, x_return, y_return, width_return, height_return)
	Display *		display
	int			screen
	char *			position
	char *			default_position
	unsigned int		bwidth
	unsigned int		fwidth
	unsigned int		fheight
	int			xadder
	int			yadder
	int *			x_return
	int *			y_return
	int *			width_return
	int *			height_return

char *
XGetAtomName(display, atom)
	Display *		display
	Atom			atom

int
XGetClassHint(display, w, class_hints_return)
	Display *		display
	Window			w
	XClassHint *		class_hints_return

int
XGetCommand(display, w, argv_return, argc_return)
	Display *		display
	Window			w
	char ***		argv_return
	int *			argc_return

char *
XGetDefault(display, program, option)
	Display *		display
	char *			program
	char *			option

int
XGetErrorDatabaseText(display, name, message, default_string, buffer_return, length)
	Display *		display
	char *			name
	char *			message
	char *			default_string
	char *			buffer_return
	int			length

int
XGetErrorText(display, code, buffer_return, length)
	Display *		display
	int			code
	char *			buffer_return
	int			length

char **
XGetFontPath(display, npaths_return)
	Display *		display
	int *			npaths_return

int
XGetFontProperty(font_struct, atom, value_return)
	XFontStruct *		font_struct
	Atom			atom
	unsigned long *		value_return

int
XGetGCValues(display, gc, valuemask, values_return)
	Display *		display
	GC			gc
	unsigned long		valuemask
	XGCValues *		values_return

int
XGetGeometry(display, d, root_return, x_return, y_return, width_return, height_return, border_width_return, depth_return)
	Display *		display
	Drawable		d
	Window *		root_return
	int *			x_return
	int *			y_return
	unsigned int *		width_return
	unsigned int *		height_return
	unsigned int *		border_width_return
	unsigned int *		depth_return

int
XGetIconName(display, w, icon_name_return)
	Display *		display
	Window			w
	char **			icon_name_return

int
XGetIconSizes(display, w, size_list_return, count_return)
	Display *		display
	Window			w
	XIconSize **		size_list_return
	int *			count_return

XImage *
XGetImage(display, d, x, y, width, height, plane_mask, format)
	Display *		display
	Drawable		d
	int			x
	int			y
	unsigned int		width
	unsigned int		height
	unsigned long		plane_mask
	int			format

int
XGetInputFocus(display, focus_return, revert_to_return)
	Display *		display
	Window *		focus_return
	int *			revert_to_return

int
XGetKeyboardControl(display, values_return)
	Display *		display
	XKeyboardState *	values_return

KeySym *
XGetKeyboardMapping(display, first_keycode, keycode_count, keysyms_per_keycode_return)
	Display *		display
	unsigned int		first_keycode
	int			keycode_count
	int *			keysyms_per_keycode_return

XModifierKeymap *
XGetModifierMapping(display)
	Display *		display

XTimeCoord *
XGetMotionEvents(display, w, start, stop, nevents_return)
	Display *		display
	Window			w
	Time			start
	Time			stop
	int *			nevents_return

int
XGetNormalHints(display, w, hints_return)
	Display *		display
	Window			w
	XSizeHints *		hints_return

int
XGetPointerControl(display, accel_numerator_return, accel_denominator_return, threshold_return)
	Display *		display
	int *			accel_numerator_return
	int *			accel_denominator_return
	int *			threshold_return

int
XGetPointerMapping(display, map_return, nmap)
	Display *		display
	unsigned char *		map_return
	int			nmap

int
XGetRGBColormaps(display, w, stdcmap_return, count_return, property)
	Display *		display
	Window			w
	XStandardColormap **	stdcmap_return
	int *			count_return
	Atom			property

int
XGetScreenSaver(display, timeout_return, interval_return, prefer_blanking_return, allow_exposures_return)
	Display *		display
	int *			timeout_return
	int *			interval_return
	int *			prefer_blanking_return
	int *			allow_exposures_return

Window
XGetSelectionOwner(display, selection)
	Display *		display
	Atom			selection

int
XGetSizeHints(display, w, hints_return, property)
	Display *		display
	Window			w
	XSizeHints *		hints_return
	Atom			property

int
XGetStandardColormap(display, w, colormap_return, property)
	Display *		display
	Window			w
	XStandardColormap *	colormap_return
	Atom			property

XImage *
XGetSubImage(display, d, x, y, width, height, plane_mask, format, dest_image, dest_x, dest_y)
	Display *		display
	Drawable		d
	int			x
	int			y
	unsigned int		width
	unsigned int		height
	unsigned long		plane_mask
	int			format
	XImage *		dest_image
	int			dest_x
	int			dest_y

int
XGetTextProperty(display, window, text_prop_return, property)
	Display *		display
	Window			window
	XTextProperty *		text_prop_return
	Atom			property

int
XGetTransientForHint(display, w, prop_window_return)
	Display *		display
	Window			w
	Window *		prop_window_return

XVisualInfo *
XGetVisualInfo(display, vinfo_mask, vinfo_template, nitems_return)
	Display *		display
	long			vinfo_mask
	XVisualInfo *		vinfo_template
	int *			nitems_return

int
XGetWMClientMachine(display, w, text_prop_return)
	Display *		display
	Window			w
	XTextProperty *		text_prop_return

int
XGetWMColormapWindows(display, w, windows_return, count_return)
	Display *		display
	Window			w
	Window **		windows_return
	int *			count_return

XWMHints *
XGetWMHints(display, w)
	Display *		display
	Window			w

int
XGetWMIconName(display, w, text_prop_return)
	Display *		display
	Window			w
	XTextProperty *		text_prop_return

int
XGetWMName(display, w, text_prop_return)
	Display *		display
	Window			w
	XTextProperty *		text_prop_return

int
XGetWMNormalHints(display, w, hints_return, supplied_return)
	Display *		display
	Window			w
	XSizeHints *		hints_return
	long *			supplied_return

int
XGetWMProtocols(display, w, protocols_return, count_return)
	Display *		display
	Window			w
	Atom **			protocols_return
	int *			count_return

int
XGetWMSizeHints(display, w, hints_return, supplied_return, property)
	Display *		display
	Window			w
	XSizeHints *		hints_return
	long *			supplied_return
	Atom			property

int
XGetWindowAttributes(display, w, window_attributes_return)
	Display *		display
	Window			w
	XWindowAttributes *	window_attributes_return

int
XGetWindowProperty(display, w, property, long_offset, long_length, delete, req_type, actual_type_return, actual_format_return, nitems_return, bytes_after_return, prop_return)
	Display *		display
	Window			w
	Atom			property
	long			long_offset
	long			long_length
	int			delete
	Atom			req_type
	Atom *			actual_type_return
	int *			actual_format_return
	unsigned long *		nitems_return
	unsigned long *		bytes_after_return
	unsigned char **	prop_return

int
XGetZoomHints(display, w, zhints_return)
	Display *		display
	Window			w
	XSizeHints *		zhints_return

int
XGrabButton(display, button, modifiers, grab_window, owner_events, event_mask, pointer_mode, keyboard_mode, confine_to, cursor)
	Display *		display
	unsigned int		button
	unsigned int		modifiers
	Window			grab_window
	int			owner_events
	unsigned int		event_mask
	int			pointer_mode
	int			keyboard_mode
	Window			confine_to
	Cursor			cursor

int
XGrabKey(display, keycode, modifiers, grab_window, owner_events, pointer_mode, keyboard_mode)
	Display *		display
	int			keycode
	unsigned int		modifiers
	Window			grab_window
	int			owner_events
	int			pointer_mode
	int			keyboard_mode

int
XGrabKeyboard(display, grab_window, owner_events, pointer_mode, keyboard_mode, time)
	Display *		display
	Window			grab_window
	int			owner_events
	int			pointer_mode
	int			keyboard_mode
	Time			time

int
XGrabPointer(display, grab_window, owner_events, event_mask, pointer_mode, keyboard_mode, confine_to, cursor, time)
	Display *		display
	Window			grab_window
	int			owner_events
	unsigned int		event_mask
	int			pointer_mode
	int			keyboard_mode
	Window			confine_to
	Cursor			cursor
	Time			time

int
XGrabServer(display)
	Display *		display

int
XHeightMMOfScreen(screen)
	Screen *		screen

int
XHeightOfScreen(screen)
	Screen *		screen

int
XIconifyWindow(display, w, screen_number)
	Display *		display
	Window			w
	int			screen_number

int
XImageByteOrder(display)
	Display *		display

XModifierKeymap *
XInsertModifiermapEntry(modmap, keycode_entry, modifier)
	XModifierKeymap *	modmap
	unsigned int		keycode_entry
	int			modifier

int
XInstallColormap(display, colormap)
	Display *		display
	Colormap		colormap

Atom
XInternAtom(display, atom_name, only_if_exists)
	Display *		display
	char *			atom_name
	int			only_if_exists

int
XIntersectRegion(sra, srb, dr_return)
	Region			sra
	Region			srb
	Region			dr_return

KeySym
XKeycodeToKeysym(display, keycode, index)
	Display *		display
	unsigned int		keycode
	int			index

KeyCode
XKeysymToKeycode(display, keysym)
	Display *		display
	KeySym			keysym

char *
XKeysymToString(keysym)
	KeySym			keysym

int
XKillClient(display, resource)
	Display *		display
	XID			resource

unsigned long
XLastKnownRequestProcessed(display)
	Display *		display

int *
XListDepths(display, screen_number, count_return)
	Display *		display
	int			screen_number
	int *			count_return

char **
XListExtensions(display, nextensions_return)
	Display *		display
	int *			nextensions_return

char **
XListFonts(display, pattern, maxnames, actual_count_return)
	Display *		display
	char *			pattern
	int			maxnames
	int *			actual_count_return

char **
XListFontsWithInfo(display, pattern, maxnames, count_return, info_return)
	Display *		display
	char *			pattern
	int			maxnames
	int *			count_return
	XFontStruct **		info_return

XHostAddress *
XListHosts(display, nhosts_return, state_return)
	Display *		display
	int *			nhosts_return
	int *			state_return

Colormap *
XListInstalledColormaps(display, w, num_return)
	Display *		display
	Window			w
	int *			num_return

XPixmapFormatValues *
XListPixmapFormats(display, count_return)
	Display *		display
	int *			count_return

Atom *
XListProperties(display, w, num_prop_return)
	Display *		display
	Window			w
	int *			num_prop_return

Font
XLoadFont(display, name)
	Display *		display
	char *			name

XFontStruct *
XLoadQueryFont(display, name)
	Display *		display
	char *			name

char *
XLocaleOfFontSet(font_set)
	XFontSet		font_set

int
XLookupColor(display, colormap, color_name, exact_def_return, screen_def_return)
	Display *		display
	Colormap		colormap
	char *			color_name
	XColor *		exact_def_return
	XColor *		screen_def_return

KeySym
XLookupKeysym(key_event, index)
	XKeyEvent *		key_event
	int			index

int
XLookupString(event_struct, buffer_return, bytes_buffer, keysym_return, status_in_out)
	XKeyEvent *		event_struct
	char *			buffer_return
	int			bytes_buffer
	KeySym *		keysym_return
	XComposeStatus *	status_in_out

int
XLowerWindow(display, w)
	Display *		display
	Window			w

int
XMapRaised(display, w)
	Display *		display
	Window			w

int
XMapSubwindows(display, w)
	Display *		display
	Window			w

int
XMapWindow(display, w)
	Display *		display
	Window			w

int
XMaskEvent(display, event_mask, event_return)
	Display *		display
	long			event_mask
	XEvent *		event_return

int
XMatchVisualInfo(display, screen, depth, class, vinfo_return)
	Display *		display
	int			screen
	int			depth
	int			class
	XVisualInfo *		vinfo_return

int
XMaxCmapsOfScreen(screen)
	Screen *		screen

long
XMaxRequestSize(display)
	Display *		display

int
XMinCmapsOfScreen(screen)
	Screen *		screen

int
XMoveResizeWindow(display, w, x, y, width, height)
	Display *		display
	Window			w
	int			x
	int			y
	unsigned int		width
	unsigned int		height

int
XMoveWindow(display, w, x, y)
	Display *		display
	Window			w
	int			x
	int			y

XModifierKeymap *
XNewModifiermap(max_keys_per_mod)
	int			max_keys_per_mod

int
XNextEvent(display, event_return)
	Display *		display
	XEvent *		event_return

unsigned long
XNextRequest(display)
	Display *		display

int
XNoOp(display)
	Display *		display

int
XOffsetRegion(r, dx, dy)
	Region			r
	int			dx
	int			dy

Display *
XOpenDisplay(display_name)
	char *			display_name

int
XParseColor(display, colormap, spec, exact_def_return)
	Display *		display
	Colormap		colormap
	char *			spec
	XColor *		exact_def_return

int
XParseGeometry(parsestring, x_return, y_return, width_return, height_return)
	char *			parsestring
	int *			x_return
	int *			y_return
	unsigned int *		width_return
	unsigned int *		height_return

int
XPeekEvent(display, event_return)
	Display *		display
	XEvent *		event_return

int
XPending(display)
	Display *		display

int
XPlanesOfScreen(screen)
	Screen *		screen

int
XPointInRegion(r, x, y)
	Region			r
	int			x
	int			y

Region
XPolygonRegion(points, n, fill_rule)
	XPoint *		points
	int			n
	int			fill_rule

int
XProtocolRevision(display)
	Display *		display

int
XProtocolVersion(display)
	Display *		display

int
XPutBackEvent(display, event)
	Display *		display
	XEvent *		event

int
XPutImage(display, d, gc, image, src_x, src_y, dest_x, dest_y, width, height)
	Display *		display
	Drawable		d
	GC			gc
	XImage *		image
	int			src_x
	int			src_y
	int			dest_x
	int			dest_y
	unsigned int		width
	unsigned int		height

int
XQLength(display)
	Display *		display

int
XQueryBestCursor(display, d, width, height, width_return, height_return)
	Display *		display
	Drawable		d
	unsigned int		width
	unsigned int		height
	unsigned int *		width_return
	unsigned int *		height_return

int
XQueryBestSize(display, class, which_screen, width, height, width_return, height_return)
	Display *		display
	int			class
	Drawable		which_screen
	unsigned int		width
	unsigned int		height
	unsigned int *		width_return
	unsigned int *		height_return

int
XQueryBestStipple(display, which_screen, width, height, width_return, height_return)
	Display *		display
	Drawable		which_screen
	unsigned int		width
	unsigned int		height
	unsigned int *		width_return
	unsigned int *		height_return

int
XQueryBestTile(display, which_screen, width, height, width_return, height_return)
	Display *		display
	Drawable		which_screen
	unsigned int		width
	unsigned int		height
	unsigned int *		width_return
	unsigned int *		height_return

int
XQueryColor(display, colormap, def_in_out)
	Display *		display
	Colormap		colormap
	XColor *		def_in_out

int
XQueryColors(display, colormap, defs_in_out, ncolors)
	Display *		display
	Colormap		colormap
	XColor *		defs_in_out
	int			ncolors

int
XQueryExtension(display, name, major_opcode_return, first_event_return, first_error_return)
	Display *		display
	char *			name
	int *			major_opcode_return
	int *			first_event_return
	int *			first_error_return

XFontStruct *
XQueryFont(display, font_ID)
	Display *		display
	XID			font_ID

int
XQueryPointer(display, w, root_return, child_return, root_x_return, root_y_return, win_x_return, win_y_return, mask_return)
	Display *		display
	Window			w
	Window *		root_return
	Window *		child_return
	int *			root_x_return
	int *			root_y_return
	int *			win_x_return
	int *			win_y_return
	unsigned int *		mask_return

int
XQueryTextExtents(display, font_ID, string, nchars, direction_return, font_ascent_return, font_descent_return, overall_return)
	Display *		display
	XID			font_ID
	char *			string
	int			nchars
	int *			direction_return
	int *			font_ascent_return
	int *			font_descent_return
	XCharStruct *		overall_return

int
XQueryTextExtents16(display, font_ID, string, nchars, direction_return, font_ascent_return, font_descent_return, overall_return)
	Display *		display
	XID			font_ID
	XChar2b *		string
	int			nchars
	int *			direction_return
	int *			font_ascent_return
	int *			font_descent_return
	XCharStruct *		overall_return

int
XQueryTree(display, w, root_return, parent_return, children_return, nchildren_return)
	Display *		display
	Window			w
	Window *		root_return
	Window *		parent_return
	Window **		children_return
	unsigned int *		nchildren_return

int
XRaiseWindow(display, w)
	Display *		display
	Window			w

int
XReadBitmapFile(display, d, filename, width_return, height_return, bitmap_return, x_hot_return, y_hot_return)
	Display *		display
	Drawable		d
	char *			filename
	unsigned int *		width_return
	unsigned int *		height_return
	Pixmap *		bitmap_return
	int *			x_hot_return
	int *			y_hot_return

int
XRebindKeysym(display, keysym, list, mod_count, string, bytes_string)
	Display *		display
	KeySym			keysym
	KeySym *		list
	int			mod_count
	unsigned char *		string
	int			bytes_string

int
XRecolorCursor(display, cursor, foreground_color, background_color)
	Display *		display
	Cursor			cursor
	XColor *		foreground_color
	XColor *		background_color

int
XReconfigureWMWindow(display, w, screen_number, mask, changes)
	Display *		display
	Window			w
	int			screen_number
	unsigned int		mask
	XWindowChanges *	changes

int
XRectInRegion(r, x, y, width, height)
	Region			r
	int			x
	int			y
	unsigned int		width
	unsigned int		height

int
XRefreshKeyboardMapping(event_map)
	XMappingEvent *		event_map

int
XRemoveFromSaveSet(display, w)
	Display *		display
	Window			w

int
XRemoveHost(display, host)
	Display *		display
	XHostAddress *		host

int
XRemoveHosts(display, hosts, num_hosts)
	Display *		display
	XHostAddress *		hosts
	int			num_hosts

int
XReparentWindow(display, w, parent, x, y)
	Display *		display
	Window			w
	Window			parent
	int			x
	int			y

int
XResetScreenSaver(display)
	Display *		display

int
XResizeWindow(display, w, width, height)
	Display *		display
	Window			w
	unsigned int		width
	unsigned int		height

char *
XResourceManagerString(display)
	Display *		display

int
XRestackWindows(display, windows, nwindows)
	Display *		display
	Window *		windows
	int			nwindows

Window
XRootWindow(display, screen_number)
	Display *		display
	int			screen_number

Window
XRootWindowOfScreen(screen)
	Screen *		screen

int
XRotateBuffers(display, rotate)
	Display *		display
	int			rotate

int
XRotateWindowProperties(display, w, properties, num_prop, npositions)
	Display *		display
	Window			w
	Atom *			properties
	int			num_prop
	int			npositions

int
XSaveContext(display, rid, context, data)
	Display *		display
	XID			rid
	XContext		context
	char *			data

int
XScreenCount(display)
	Display *		display

int
XScreenNumberOfScreen(screen)
	Screen *		screen

Screen *
XScreenOfDisplay(display, screen_number)
	Display *		display
	int			screen_number

char *
XScreenResourceString(screen)
	Screen *		screen

int
XSelectInput(display, w, event_mask)
	Display *		display
	Window			w
	long			event_mask

int
XSendEvent(display, w, propagate, event_mask, event_send)
	Display *		display
	Window			w
	int			propagate
	long			event_mask
	XEvent *		event_send

char *
XServerVendor(display)
	Display *		display

int
XSetAccessControl(display, mode)
	Display *		display
	int			mode

int
XSetArcMode(display, gc, arc_mode)
	Display *		display
	GC			gc
	int			arc_mode

int
XSetBackground(display, gc, background)
	Display *		display
	GC			gc
	unsigned long		background

int
XSetClassHint(display, w, class_hints)
	Display *		display
	Window			w
	XClassHint *		class_hints

int
XSetClipMask(display, gc, pixmap)
	Display *		display
	GC			gc
	Pixmap			pixmap

int
XSetClipOrigin(display, gc, clip_x_origin, clip_y_origin)
	Display *		display
	GC			gc
	int			clip_x_origin
	int			clip_y_origin

int
XSetClipRectangles(display, gc, clip_x_origin, clip_y_origin, rectangles, n, ordering)
	Display *		display
	GC			gc
	int			clip_x_origin
	int			clip_y_origin
	XRectangle *		rectangles
	int			n
	int			ordering

int
XSetCloseDownMode(display, close_mode)
	Display *		display
	int			close_mode

int
XSetCommand(display, w, argv, argc)
	Display *		display
	Window			w
	char **			argv
	int			argc

int
XSetDashes(display, gc, dash_offset, dash_list, n)
	Display *		display
	GC			gc
	int			dash_offset
	char *			dash_list
	int			n

int
XSetFillRule(display, gc, fill_rule)
	Display *		display
	GC			gc
	int			fill_rule

int
XSetFillStyle(display, gc, fill_style)
	Display *		display
	GC			gc
	int			fill_style

int
XSetFont(display, gc, font)
	Display *		display
	GC			gc
	Font			font

int
XSetFontPath(display, directories, ndirs)
	Display *		display
	char **			directories
	int			ndirs

int
XSetForeground(display, gc, foreground)
	Display *		display
	GC			gc
	unsigned long		foreground

int
XSetFunction(display, gc, function)
	Display *		display
	GC			gc
	int			function

int
XSetGraphicsExposures(display, gc, graphics_exposures)
	Display *		display
	GC			gc
	int			graphics_exposures

int
XSetIconName(display, w, icon_name)
	Display *		display
	Window			w
	char *			icon_name

int
XSetIconSizes(display, w, size_list, count)
	Display *		display
	Window			w
	XIconSize *		size_list
	int			count

int
XSetInputFocus(display, focus, revert_to, time)
	Display *		display
	Window			focus
	int			revert_to
	Time			time

int
XSetLineAttributes(display, gc, line_width, line_style, cap_style, join_style)
	Display *		display
	GC			gc
	unsigned int		line_width
	int			line_style
	int			cap_style
	int			join_style

int
XSetModifierMapping(display, modmap)
	Display *		display
	XModifierKeymap *	modmap

int
XSetNormalHints(display, w, hints)
	Display *		display
	Window			w
	XSizeHints *		hints

int
XSetPlaneMask(display, gc, plane_mask)
	Display *		display
	GC			gc
	unsigned long		plane_mask

int
XSetPointerMapping(display, map, nmap)
	Display *		display
	unsigned char *		map
	int			nmap

void
XSetRGBColormaps(display, w, stdcmaps, count, property)
	Display *		display
	Window			w
	XStandardColormap *	stdcmaps
	int			count
	Atom			property

int
XSetRegion(display, gc, r)
	Display *		display
	GC			gc
	Region			r

int
XSetScreenSaver(display, timeout, interval, prefer_blanking, allow_exposures)
	Display *		display
	int			timeout
	int			interval
	int			prefer_blanking
	int			allow_exposures

int
XSetSelectionOwner(display, selection, owner, time)
	Display *		display
	Atom			selection
	Window			owner
	Time			time

int
XSetSizeHints(display, w, hints, property)
	Display *		display
	Window			w
	XSizeHints *		hints
	Atom			property

void
XSetStandardColormap(display, w, colormap, property)
	Display *		display
	Window			w
	XStandardColormap *	colormap
	Atom			property

int
XSetStandardProperties(display, w, window_name, icon_name, icon_pixmap, argv, argc, hints)
	Display *		display
	Window			w
	char *			window_name
	char *			icon_name
	Pixmap			icon_pixmap
	char **			argv
	int			argc
	XSizeHints *		hints

int
XSetState(display, gc, foreground, background, function, plane_mask)
	Display *		display
	GC			gc
	unsigned long		foreground
	unsigned long		background
	int			function
	unsigned long		plane_mask

int
XSetStipple(display, gc, stipple)
	Display *		display
	GC			gc
	Pixmap			stipple

int
XSetSubwindowMode(display, gc, subwindow_mode)
	Display *		display
	GC			gc
	int			subwindow_mode

int
XSetTSOrigin(display, gc, ts_x_origin, ts_y_origin)
	Display *		display
	GC			gc
	int			ts_x_origin
	int			ts_y_origin

void
XSetTextProperty(display, w, text_prop, property)
	Display *		display
	Window			w
	XTextProperty *		text_prop
	Atom			property

int
XSetTile(display, gc, tile)
	Display *		display
	GC			gc
	Pixmap			tile

int
XSetTransientForHint(display, w, prop_window)
	Display *		display
	Window			w
	Window			prop_window

void
XSetWMClientMachine(display, w, text_prop)
	Display *		display
	Window			w
	XTextProperty *		text_prop

int
XSetWMColormapWindows(display, w, colormap_windows, count)
	Display *		display
	Window			w
	Window *		colormap_windows
	int			count

int
XSetWMHints(display, w, wm_hints)
	Display *		display
	Window			w
	XWMHints *		wm_hints

void
XSetWMIconName(display, w, text_prop)
	Display *		display
	Window			w
	XTextProperty *		text_prop

void
XSetWMName(display, w, text_prop)
	Display *		display
	Window			w
	XTextProperty *		text_prop

void
XSetWMNormalHints(display, w, hints)
	Display *		display
	Window			w
	XSizeHints *		hints

void
XSetWMProperties(display, w, window_name, icon_name, argv, argc, normal_hints, wm_hints, class_hints)
	Display *		display
	Window			w
	XTextProperty *		window_name
	XTextProperty *		icon_name
	char **			argv
	int			argc
	XSizeHints *		normal_hints
	XWMHints *		wm_hints
	XClassHint *		class_hints

int
XSetWMProtocols(display, w, protocols, count)
	Display *		display
	Window			w
	Atom *			protocols
	int			count

void
XSetWMSizeHints(display, w, hints, property)
	Display *		display
	Window			w
	XSizeHints *		hints
	Atom			property

int
XSetWindowBackground(display, w, background_pixel)
	Display *		display
	Window			w
	unsigned long		background_pixel

int
XSetWindowBackgroundPixmap(display, w, background_pixmap)
	Display *		display
	Window			w
	Pixmap			background_pixmap

int
XSetWindowBorder(display, w, border_pixel)
	Display *		display
	Window			w
	unsigned long		border_pixel

int
XSetWindowBorderPixmap(display, w, border_pixmap)
	Display *		display
	Window			w
	Pixmap			border_pixmap

int
XSetWindowBorderWidth(display, w, width)
	Display *		display
	Window			w
	unsigned int		width

int
XSetWindowColormap(display, w, colormap)
	Display *		display
	Window			w
	Colormap		colormap

int
XSetZoomHints(display, w, zhints)
	Display *		display
	Window			w
	XSizeHints *		zhints

int
XShrinkRegion(r, dx, dy)
	Region			r
	int			dx
	int			dy

int
XStoreBuffer(display, bytes, nbytes, buffer)
	Display *		display
	char *			bytes
	int			nbytes
	int			buffer

int
XStoreBytes(display, bytes, nbytes)
	Display *		display
	char *			bytes
	int			nbytes

int
XStoreColor(display, colormap, color)
	Display *		display
	Colormap		colormap
	XColor *		color

int
XStoreColors(display, colormap, color, ncolors)
	Display *		display
	Colormap		colormap
	XColor *		color
	int			ncolors

int
XStoreName(display, w, window_name)
	Display *		display
	Window			w
	char *			window_name

int
XStoreNamedColor(display, colormap, color, pixel, flags)
	Display *		display
	Colormap		colormap
	char *			color
	unsigned long		pixel
	int			flags

int
XStringListToTextProperty(list, count, text_prop_return)
	char **			list
	int			count
	XTextProperty *		text_prop_return

KeySym
XStringToKeysym(string)
	char *			string

int
XSubtractRegion(sra, srb, dr_return)
	Region			sra
	Region			srb
	Region			dr_return

int
XSync(display, discard)
	Display *		display
	int			discard

int
XTextExtents(font_struct, string, nchars, direction_return, font_ascent_return, font_descent_return, overall_return)
	XFontStruct *		font_struct
	char *			string
	int			nchars
	int *			direction_return
	int *			font_ascent_return
	int *			font_descent_return
	XCharStruct *		overall_return

int
XTextExtents16(font_struct, string, nchars, direction_return, font_ascent_return, font_descent_return, overall_return)
	XFontStruct *		font_struct
	XChar2b *		string
	int			nchars
	int *			direction_return
	int *			font_ascent_return
	int *			font_descent_return
	XCharStruct *		overall_return

int
XTextPropertyToStringList(text_prop, list_return, count_return)
	XTextProperty *		text_prop
	char ***		list_return
	int *			count_return

int
XTextWidth(font_struct, string, count)
	XFontStruct *		font_struct
	char *			string
	int			count

int
XTextWidth16(font_struct, string, count)
	XFontStruct *		font_struct
	XChar2b *		string
	int			count

int
XTranslateCoordinates(display, src_w, dest_w, src_x, src_y, dest_x_return, dest_y_return, child_return)
	Display *		display
	Window			src_w
	Window			dest_w
	int			src_x
	int			src_y
	int *			dest_x_return
	int *			dest_y_return
	Window *		child_return

int
XUndefineCursor(display, w)
	Display *		display
	Window			w

int
XUngrabButton(display, button, modifiers, grab_window)
	Display *		display
	unsigned int		button
	unsigned int		modifiers
	Window			grab_window

int
XUngrabKey(display, keycode, modifiers, grab_window)
	Display *		display
	int			keycode
	unsigned int		modifiers
	Window			grab_window

int
XUngrabKeyboard(display, time)
	Display *		display
	Time			time

int
XUngrabPointer(display, time)
	Display *		display
	Time			time

int
XUngrabServer(display)
	Display *		display

int
XUninstallColormap(display, colormap)
	Display *		display
	Colormap		colormap

int
XUnionRectWithRegion(rectangle, src_region, dest_region_return)
	XRectangle *		rectangle
	Region			src_region
	Region			dest_region_return

int
XUnionRegion(sra, srb, dr_return)
	Region			sra
	Region			srb
	Region			dr_return

int
XUnloadFont(display, font)
	Display *		display
	Font			font

int
XUnmapSubwindows(display, w)
	Display *		display
	Window			w

int
XUnmapWindow(display, w)
	Display *		display
	Window			w

int
XVendorRelease(display)
	Display *		display

VisualID
XVisualIDFromVisual(visual)
	Visual *		visual

int
XWMGeometry(display, screen_number, user_geometry, default_geometry, border_width, hints, x_return, y_return, width_return, height_return, gravity_return)
	Display *		display
	int			screen_number
	char *			user_geometry
	char *			default_geometry
	unsigned int		border_width
	XSizeHints *		hints
	int *			x_return
	int *			y_return
	int *			width_return
	int *			height_return
	int *			gravity_return

int
XWarpPointer(display, src_w, dest_w, src_x, src_y, src_width, src_height, dest_x, dest_y)
	Display *		display
	Window			src_w
	Window			dest_w
	int			src_x
	int			src_y
	unsigned int		src_width
	unsigned int		src_height
	int			dest_x
	int			dest_y

unsigned long
XWhitePixel(display, screen_number)
	Display *		display
	int			screen_number

unsigned long
XWhitePixelOfScreen(screen)
	Screen *		screen

int
XWidthMMOfScreen(screen)
	Screen *		screen

int
XWidthOfScreen(screen)
	Screen *		screen

int
XWindowEvent(display, w, event_mask, event_return)
	Display *		display
	Window			w
	long			event_mask
	XEvent *		event_return

int
XWithdrawWindow(display, w, screen_number)
	Display *		display
	Window			w
	int			screen_number

int
XWriteBitmapFile(display, filename, bitmap, width, height, x_hot, y_hot)
	Display *		display
	char *			filename
	Pixmap			bitmap
	unsigned int		width
	unsigned int		height
	int			x_hot
	int			y_hot

int
XXorRegion(sra, srb, dr_return)
	Region			sra
	Region			srb
	Region			dr_return

void
XrmCombineDatabase(source_db, target_db, override)
	XrmDatabase		source_db
	XrmDatabase *		target_db
	int			override

int
XrmCombineFileDatabase(filename, target, override)
	char *			filename
	XrmDatabase *		target
	int			override

void
XrmDestroyDatabase(database)
	XrmDatabase		database

XrmDatabase
XrmGetDatabase(display)
	Display *		display

XrmDatabase
XrmGetFileDatabase(filename)
	char *			filename

int
XrmGetResource(database, str_name, str_class, str_type_return, value_return)
	XrmDatabase		database
	char *			str_name
	char *			str_class
	char **			str_type_return
	XrmValue *		value_return

XrmDatabase
XrmGetStringDatabase(data)
	char *			data

void
XrmInitialize()


char *
XrmLocaleOfDatabase(database)
	XrmDatabase		database

void
XrmMergeDatabases(source_db, target_db)
	XrmDatabase		source_db
	XrmDatabase *		target_db

void
XrmParseCommand(database, table, table_count, name, argc_in_out, argv_in_out)
	XrmDatabase *		database
	XrmOptionDescList	table
	int			table_count
	char *			name
	int *			argc_in_out
	char **			argv_in_out

XrmQuark
XrmPermStringToQuark(string)
	char *			string

void
XrmPutFileDatabase(database, filename)
	XrmDatabase		database
	char *			filename

void
XrmPutLineResource(database, line)
	XrmDatabase *		database
	char *			line

void
XrmPutResource(database, specifier, type, value)
	XrmDatabase *		database
	char *			specifier
	char *			type
	XrmValue *		value

void
XrmPutStringResource(database, specifier, value)
	XrmDatabase *		database
	char *			specifier
	char *			value

int
XrmQGetResource(database, quark_name, quark_class, quark_type_return, value_return)
	XrmDatabase		database
	XrmNameList		quark_name
	XrmClassList		quark_class
	XrmRepresentation *	quark_type_return
	XrmValue *		value_return

void
XrmQPutResource(database, bindings, quarks, type, value)
	XrmDatabase *		database
	XrmBindingList		bindings
	XrmQuarkList		quarks
	XrmRepresentation	type
	XrmValue *		value

void
XrmQPutStringResource(database, bindings, quarks, value)
	XrmDatabase *		database
	XrmBindingList		bindings
	XrmQuarkList		quarks
	char *			value

XrmString
XrmQuarkToString(quark)
	XrmQuark		quark

void
XrmSetDatabase(display, database)
	Display *		display
	XrmDatabase		database

void
XrmStringToBindingQuarkList(string, bindings_return, quarks_return)
	char *			string
	XrmBindingList		bindings_return
	XrmQuarkList		quarks_return

XrmQuark
XrmStringToQuark(string)
	char *			string

void
XrmStringToQuarkList(string, quarks_return)
	char *			string
	XrmQuarkList		quarks_return

XrmQuark
XrmUniqueQuark()


# -- END list-raw-funs OUTPUT --



MODULE = X11::Lib		PACKAGE = X::Event

unsigned long
serial(e)
    XEvent *			e
    CODE:
	RETVAL = e->xany.serial;
    OUTPUT:
	RETVAL

int
send_event(e)
    XEvent *			e
    CODE:
	RETVAL = e->xany.send_event;
    OUTPUT:
	RETVAL

Display *
display(e)
    XEvent *			e
    CODE:
	RETVAL = e->xany.display;
    OUTPUT:
	RETVAL

Window
window(e)
    XEvent *			e
    CODE:
	RETVAL = e->xany.window;
    OUTPUT:
	RETVAL

MODULE = X11::Lib		PACKAGE = X::Event::_XY

int
x(e)
    XEvent *			e
    CODE:
	RETVAL = e->xbutton.x;
    OUTPUT:
	RETVAL

int
y(e)
    XEvent *			e
    CODE:
	RETVAL = e->xbutton.y;
    OUTPUT:
	RETVAL

Window
root(e)
    XEvent *			e
    CODE:
	RETVAL = e->xbutton.root;
    OUTPUT:
	RETVAL

Window
subwindow(e)
    XEvent *			e
    CODE:
	RETVAL = e->xbutton.subwindow;
    OUTPUT:
	RETVAL

Time
time(e)
    XEvent *			e
    CODE:
	RETVAL = e->xbutton.time;
    OUTPUT:
	RETVAL

MODULE = X11::Lib		PACKAGE = X::Event::_Expose

int
x(e)
    XEvent *			e
    CODE:
	RETVAL = e->xexpose.x;
    OUTPUT:
	RETVAL

int
y(e)
    XEvent *			e
    CODE:
	RETVAL = e->xexpose.y;
    OUTPUT:
	RETVAL

int
width(e)
    XEvent *			e
    CODE:
	RETVAL = e->xexpose.width;
    OUTPUT:
	RETVAL

int
height(e)
    XEvent *			e
    CODE:
	RETVAL = e->xexpose.height;
    OUTPUT:
	RETVAL

MODULE = X11::Lib		PACKAGE = X::Event::MotionEvent

MODULE = X11::Lib		PACKAGE = X::Event::ButtonEvent

MODULE = X11::Lib		PACKAGE = X::Event::ColormapEvent

MODULE = X11::Lib		PACKAGE = X::Event::CrossingEvent

MODULE = X11::Lib		PACKAGE = X::Event::ExposeEvent

MODULE = X11::Lib		PACKAGE = X::Event::GraphicsExposeEvent

MODULE = X11::Lib		PACKAGE = X::Event::NoExposeEvent

MODULE = X11::Lib		PACKAGE = X::Event::FocusChangeEvent

MODULE = X11::Lib		PACKAGE = X::Event::KeymapEvent

MODULE = X11::Lib		PACKAGE = X::Event::KeyEvent

MODULE = X11::Lib		PACKAGE = X::Event::PropertyEvent

MODULE = X11::Lib		PACKAGE = X::Event::ResizeRequestEvent

MODULE = X11::Lib		PACKAGE = X::Event::CirculateEvent

MODULE = X11::Lib		PACKAGE = X::Event::ConfigureEvent

MODULE = X11::Lib		PACKAGE = X::Event::CreateEvent

MODULE = X11::Lib		PACKAGE = X::Event::DestroyEvent

MODULE = X11::Lib		PACKAGE = X::Event::GravityEvent

MODULE = X11::Lib		PACKAGE = X::Event::MapEvent

MODULE = X11::Lib		PACKAGE = X::Event::ReparentEvent

MODULE = X11::Lib		PACKAGE = X::Event::UnmapEvent

MODULE = X11::Lib		PACKAGE = X::Event::CirculateRequestEvent

MODULE = X11::Lib		PACKAGE = X::Event::ConfigureRequestEvent

MODULE = X11::Lib		PACKAGE = X::Event::MapRequestEvent

MODULE = X11::Lib		PACKAGE = X::Event::ClientMessageEvent

MODULE = X11::Lib		PACKAGE = X::Event::MappingEvent

MODULE = X11::Lib		PACKAGE = X::Event::SelectionClearEvent

MODULE = X11::Lib		PACKAGE = X::Event::SelectionEvent

MODULE = X11::Lib		PACKAGE = X::Event::SelectionRequestEvent

MODULE = X11::Lib		PACKAGE = X::Event::VisibilityEvent


MODULE = X11::Lib		PACKAGE = X::GCValues

XGCValues *
new(classname)
	char *			classname
	CODE:
	    RETVAL = (XGCValues *)malloc(sizeof(XGCValues));
	OUTPUT:
	    RETVAL

void
DESTROY(self)
	XGCValues *		self
	CODE:
	    if (self) free(self);
