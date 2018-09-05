
/* Copyright 1997, 1998 by Ken Fox */

#include <X11/xpm.h>
#undef FUNC

#include "x-api.h"

static void get_visual_info(Visual **visual, Colormap *colormap, int *depth,
			    SV *visual_in, SV *colormap_in, SV *depth_in)
{
    if (visual_in && SvOK(visual_in)) {
	if (sv_derived_from(visual_in, VisualPtr_Package) &&
	    colormap_in && SvOK(colormap_in) && sv_derived_from(colormap_in, Colormap_Package) &&
	    depth_in && SvOK(depth_in))
	{
	    IV tmp_ = SvIV((SV*)SvRV(visual_in));
	    *visual = (Visual *)tmp_;
	    *colormap = (Colormap)SvIV((SV*)SvRV(colormap_in));
	    *depth = (int)SvIV(depth_in);
	}
	else {
	    croak("when using a non-default visual, you must provide the visual, a colormap and the depth");
	}
    }
}

MODULE = X11::Xpm		PACKAGE = X::Xpm

PROTOTYPES: ENABLE

void
ReadFileToPixmap(display, d, filename, visual_in = 0, colormap_in = 0, depth_in = 0)
	Display *		display
	Drawable		d
	char *			filename
	SV *			visual_in
	SV *			colormap_in
	SV *			depth_in
	PREINIT:
	    int r;
	    Pixmap icon;
	    Pixmap mask;
	    XpmAttributes attrib;
	    Visual *visual = 0;
	    Colormap colormap;
	    int depth;
	PPCODE:
	    get_visual_info(&visual, &colormap, &depth, visual_in, colormap_in, depth_in);
	    attrib.valuemask = 0;
	    if (visual) {
		attrib.valuemask |= XpmVisual|XpmColormap|XpmDepth;
		attrib.visual = visual;
		attrib.colormap = colormap;
		attrib.depth = (unsigned int)depth;
	    }
	    r = XpmReadFileToPixmap(display, d, filename, &icon, &mask, &attrib);
	    if (r == XpmSuccess) {
		XPUSHs(sv_setref_pv(sv_newmortal(), Pixmap_Package, (void *)icon));
		if (mask) {
		    XPUSHs(sv_setref_pv(sv_newmortal(), Pixmap_Package, (void *)mask));
		}
	    }

void
CreatePixmapFromData_array(display, d, data_in, visual_in = 0, colormap_in = 0, depth_in = 0)
	Display *		display
	Drawable		d
	SV *			data_in
	SV *			visual_in
	SV *			colormap_in
	SV *			depth_in
	PREINIT:
	    int r, len;
	    Pixmap icon;
	    Pixmap mask;
	    SV **sv;
	    AV *av;
	    char **data;
	    XpmAttributes attrib;
	    Visual *visual = 0;
	    Colormap colormap;
	    int depth;
	PPCODE:
	    get_visual_info(&visual, &colormap, &depth, visual_in, colormap_in, depth_in);
	    if (SvROK(data_in) && SvTYPE(SvRV(data_in)) == SVt_PVAV) {
		av = (AV *)SvRV(data_in);
		len = AvFILL(av) + 1;
	    }
	    else {
		croak("data_in is not an array reference");
	    }
	    if ((data = malloc((len + 1) * sizeof(char *))) == 0) {
		croak("not enough memory for Xpm data");
	    }
	    for (r = 0; r < len; ++r) {
		sv = av_fetch(av, r, 0);
		if (sv) {
		    data[r] = SvPV(*sv, na);
		}
		else {
		    data[r] = "";
		}
	    }
	    data[r] = 0;
	    attrib.valuemask = 0;
	    if (visual) {
		attrib.valuemask |= XpmVisual|XpmColormap|XpmDepth;
		attrib.visual = visual;
		attrib.colormap = colormap;
		attrib.depth = (unsigned int)depth;
	    }
	    r = XpmCreatePixmapFromData(display, d, data, &icon, &mask, &attrib);
	    if (r == XpmSuccess) {
		XPUSHs(sv_setref_pv(sv_newmortal(), Pixmap_Package, (void *)icon));
		if (mask) {
		    XPUSHs(sv_setref_pv(sv_newmortal(), Pixmap_Package, (void *)mask));
		}
	    }
	    free(data);
