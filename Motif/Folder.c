
#include <stdarg.h>
#include <stdlib.h>

#include <X11/IntrinsicP.h>
#include <X11/StringDefs.h>

#include <Xm/XmP.h>
#include <Xm/PrimitiveP.h>
#include <Xm/ManagerP.h>
#include <X11/ConstrainP.h>

#include <Xm/PushB.h>

#include "FolderP.h"
#include "StackP.h"

#define Offset(field)	XtOffsetOf(FolderRec, folder.field)

static XtResource resources[] =
{
    { XtNoutsideMargin, XtCOutsideMargin, XtRDimension, sizeof(Dimension),
      Offset(outside_margin), XtRImmediate, (XtPointer)4},

    { XtNtabPosition, XtCTabPosition, XtRString, sizeof(String),
      Offset(tab_position), XtRString, "left" },

    { XtNtabAlignment, XtCTabAlignment, XtRString, sizeof(String),
      Offset(tab_alignment), XtRString, "left" },

    { XtNallowScrollingTabs, XtCAllowScrollingTabs, XtRBoolean, sizeof(Boolean),
      Offset(allow_scrolling_tabs), XtRImmediate, (XtPointer)True },

    { XtNtabHeight, XtCTabHeight, XtRDimension, sizeof(Dimension),
      Offset(tab_height), XtRImmediate, (XtPointer)0 },

    { XtNtabSlantWidth, XtCTabSlantWidth, XtRDimension, sizeof(Dimension),
      Offset(tab_slant_width), XtRImmediate, (XtPointer)0 },

    { XtNtabMargin, XtCTabMargin, XtRDimension, sizeof(Dimension),
      Offset(tab_margin), XtRImmediate, (XtPointer)4 },

    { XtNtabFont, XtCTabFont, XtRFontStruct, sizeof(XFontStruct *),
      Offset(tab_font), XtRString, "XtDefaultFont" },

    { XtNforeground, XtCForeground, XtRPixel, sizeof(Pixel),
      Offset(foreground), XtRString, "XtDefaultForeground" },

    { XtNtopFolderColor, XtCTopFolderColor, XtRPixel, sizeof(Pixel),
      Offset(top_folder_color), XtRString, "white" },

    { XtNbottomFolderColor, XtCBottomFolderColor, XtRPixel, sizeof(Pixel),
      Offset(bottom_folder_color), XtRString, "grey" },
};

#undef Offset

extern WidgetClass folderWidgetClass;

inline int max(int x, int y)
{
    if (x > y) return(x);
    return(y);
}

#define MAX_SEGMENTS 10

static Pixmap create_stick_figure(FolderWidget self, int width, int offset[], int length[], int direction)
{
    XSegment segments[MAX_SEGMENTS];
    Pixmap arrow;
    int i;

    if (width > MAX_SEGMENTS) width = MAX_SEGMENTS;

    arrow = XCreatePixmap(XtDisplay(self), XtWindow(self),
			  width, length[0], self->core.depth);

    for (i = 0; i < width; ++i)
    {
	segments[i].x1 = i;
	segments[i].x2 = i;

	if (direction < 1)
	{
	    segments[i].y1 = offset[width - i - 1];
	    segments[i].y2 = segments[i].y1 + length[width - i - 1] - 1;
	}
	else
	{
	    segments[i].y1 = offset[i];
	    segments[i].y2 = segments[i].y1 + length[i] - 1;
	}
    }

    XSetForeground(XtDisplay(self), self->folder.tab_gc, self->core.background_pixel);
    XFillRectangle(XtDisplay(self), arrow, self->folder.tab_gc, 0, 0, width, length[0]);

    XSetForeground(XtDisplay(self), self->folder.tab_gc, self->folder.foreground);
    XDrawSegments(XtDisplay(self), arrow, self->folder.tab_gc, segments, width);

    return(arrow);
}

#define ARROW_WIDTH 6

static void create_arrow_pixmaps(FolderWidget self)
{
    static int offset[ARROW_WIDTH] = {  0,  1,  3,  5, 7, 9 };
    static int length[ARROW_WIDTH] = { 20, 18, 14, 10, 6, 2 };

    if (self->folder.left_arrow_pixmap == 0)
    {
	self->folder.left_arrow_pixmap = create_stick_figure(self, ARROW_WIDTH, offset, length, -1);
    }

    if (self->folder.right_arrow_pixmap == 0)
    {
	self->folder.right_arrow_pixmap = create_stick_figure(self, ARROW_WIDTH, offset, length, 1);
    }
}

static Widget GetNthWidget(FolderWidget self, int i)
{
    if (self && self->composite.num_children > i)
    {
	return(self->composite.children[i]);
    }

    return(0);
}

static Widget GetStackWidget(FolderWidget self)
{
    return(GetNthWidget(self, 0));
}

static Widget GetTabsWidget(FolderWidget self)
{
    return(GetNthWidget(self, 1));
}

static Widget GetLeftArrowWidget(FolderWidget self)
{
    return(GetNthWidget(self, 2));
}

static Widget GetRightArrowWidget(FolderWidget self)
{
    return(GetNthWidget(self, 3));
}

static void compute_size(FolderWidget self)
{
    Dimension margin_space, stack_width, stack_height;
    XtWidgetGeometry desired_by_stack;

    XtQueryGeometry(GetStackWidget(self), 0, &desired_by_stack);

    margin_space = self->core.border_width * 2 + self->folder.outside_margin * 2;
    stack_width = desired_by_stack.width;
    stack_height = desired_by_stack.height;

    self->core.width = margin_space + stack_width;
    self->core.height = margin_space + self->folder.tab_height + stack_height;
}

static void draw_tab(FolderWidget self, Widget tabs, Boolean active, StackConstraint layer_info)
{
    Position x, y;
    XPoint points[4];

    x = layer_info->stack.tab_position - self->folder.current_tab_offset;
    y = 0;

    XSetForeground(XtDisplay(tabs), self->folder.tab_gc,
		   (active) ? self->folder.top_folder_color : self->folder.bottom_folder_color);

    points[0].x = x + 1;
    points[0].y = self->folder.tab_height;

    points[1].x = points[0].x;
    points[1].y = self->folder.tab_margin;

    points[2].x = x + layer_info->stack.tab_length - self->folder.tab_slant_width;
    points[2].y = points[1].y;

    points[3].x = x + layer_info->stack.tab_length;
    points[3].y = points[0].y;

    XFillPolygon(XtDisplay(tabs), XtWindow(tabs), self->folder.tab_gc,
		 points, 4, Convex, CoordModeOrigin);

    XSetForeground(XtDisplay(tabs), self->folder.tab_gc, self->folder.foreground);

    XDrawLines(XtDisplay(tabs), XtWindow(tabs), self->folder.tab_gc,
	       points, 4, CoordModeOrigin);

    XSetForeground(XtDisplay(tabs), self->folder.tab_gc, self->folder.foreground);

    if (layer_info->stack.name_1)
    {
	x += max(self->folder.tab_margin * 2, 8);
	y += layer_info->stack.tab_starting_line;

	XDrawString(XtDisplay(tabs), XtWindow(tabs), self->folder.tab_gc,
		    x, y, layer_info->stack.name_1, layer_info->stack.length_1);

	if (layer_info->stack.length_2)
	{
	    y += self->folder.tab_font->max_bounds.ascent + 1;

	    XDrawString(XtDisplay(tabs), XtWindow(tabs), self->folder.tab_gc,
			x, y, layer_info->stack.name_2, layer_info->stack.length_2);
	}
    }
}

static void redraw_tabs(FolderWidget self)
{
    StackWidget stack = (StackWidget)GetStackWidget(self);
    Widget tabs, left, right;
    Widget child;
    StackConstraint layer_info;
    Boolean more_on_left = False, more_on_right = False;
    Position margin = self->core.border_width + self->folder.outside_margin;
    Dimension total_width = self->core.width - margin * 2;
    Dimension total_height = self->core.height - margin * 2;
    Dimension width;
    int active_child = -1;
    int i, position;

    tabs = GetTabsWidget(self);
    active_child = StackGetActiveChild((Widget)stack);

    /* The first pass through the stack children figures out whether there
       will be undisplayed (or partially displayed) tabs to either the left
       or the right.  This information is used in deciding whether to add
       the left/right scroll arrows and for computing the actual size of
       tab display window. */

    /* Start out assuming that the entire width will be available (i.e. all
       tabs displayed over the entire width. */

    width = total_width;

    if (self->folder.allow_scrolling_tabs)
    {
	/* Find out if tabs are undisplayed to the left -- if so, reduce the available
	   width by the width of the scroll arrow. */

	for (i = 0; i < stack->composite.num_children; ++i)
	{
	    child = stack->composite.children[i];

	    if (XtIsManaged(child))
	    {
		layer_info = (StackConstraint)child->core.constraints;
		position = layer_info->stack.tab_position - self->folder.current_tab_offset;

		if (position < 0)
		{
		    width -= self->folder.arrow_width;
		    more_on_left = True;
		    break;
		}
	    }
	}

	/* Now find out if tabs are undisplayed to the right -- if so, reduce the
	   available width by the width of the scroll arrow again. */

	for (i = 0; i < stack->composite.num_children; ++i)
	{
	    child = stack->composite.children[i];

	    if (XtIsManaged(child))
	    {
		layer_info = (StackConstraint)child->core.constraints;
		position = layer_info->stack.tab_position - self->folder.current_tab_offset;

		if (position + layer_info->stack.tab_length > width)
		{
		    width -= self->folder.arrow_width;
		    more_on_right = True;
		    break;
		}
	    }
	}
    }

    /* If any tabs were discovered to be undisplayed, the left/right arrows and
       the tab display area must be reconfigured.  The arrows never change
       location and so they merely need to be mapped or unmapped.  The tab
       display area may change location and/or size. */

    left = GetLeftArrowWidget(self);
    right = GetRightArrowWidget(self);

    if (more_on_left && more_on_right)
    {
	XMapWindow(XtDisplay(left), XtWindow(left));
	XMapWindow(XtDisplay(right), XtWindow(right));

	XtConfigureWidget(tabs, margin + self->folder.arrow_width, margin, width,
			  self->folder.tab_height, 0);
    }
    else if (more_on_left)
    {
	XMapWindow(XtDisplay(left), XtWindow(left));
	XUnmapWindow(XtDisplay(right), XtWindow(right));

	XtConfigureWidget(tabs, margin + self->folder.arrow_width, margin, width,
			  self->folder.tab_height, 0);
    }
    else if (more_on_right)
    {
	XUnmapWindow(XtDisplay(left), XtWindow(left));
	XMapWindow(XtDisplay(right), XtWindow(right));

	XtConfigureWidget(tabs, margin, margin, width,
			  self->folder.tab_height, 0);
    }
    else
    {
	XUnmapWindow(XtDisplay(left), XtWindow(left));
	XUnmapWindow(XtDisplay(right), XtWindow(right));

	XtConfigureWidget(tabs, margin, margin, width,
			  self->folder.tab_height, 0);
    }

    /* The rest of the code merely draws the tabs. */

    for (i = stack->composite.num_children - 1; i >= 0; --i)
    {
	child = stack->composite.children[i];

	if (i != active_child && XtIsManaged(child))
	{
	    int position;

	    layer_info = (StackConstraint)child->core.constraints;
	    position = layer_info->stack.tab_position - self->folder.current_tab_offset;

	    if (position < width && position + layer_info->stack.tab_length >= 0)
	    {
		draw_tab(self, tabs, False, layer_info);
	    }
	}
    }

    XDrawLine(XtDisplay(tabs), XtWindow(tabs), self->folder.tab_gc,
	      0, self->folder.tab_height - 1, tabs->core.width, self->folder.tab_height - 1);

    if (active_child != -1)
    {
	layer_info = (StackConstraint)stack->composite.children[active_child]->core.constraints;
	draw_tab(self, tabs, True, layer_info);
    }
}

static void update_tabs_if_necessary(FolderWidget self)
{
    Widget child;

    if (XtIsRealized(self))
    {
	child = GetTabsWidget(self);
	XClearWindow(XtDisplay(child), XtWindow(child));
	redraw_tabs(self);
    }
}

static void Resize(Widget w)
{
    FolderWidget self = (FolderWidget)w;
    Position margin = self->core.border_width + self->folder.outside_margin;
    Dimension total_width = self->core.width - margin * 2;
    Dimension total_height = self->core.height - margin * 2;
    Position x, y;
    Dimension width, height;
    Widget child;

    if (total_width < self->folder.arrow_width * 2) total_width = self->folder.arrow_width * 2 + 1;
    if (total_height < self->folder.tab_height) total_height = self->folder.tab_height + 1;

    child = GetLeftArrowWidget(self);
    x = margin;
    y = margin;
    width = self->folder.arrow_width;
    height = self->folder.tab_height;
    XtConfigureWidget(child, x, y, width, height, 0);

    child = GetRightArrowWidget(self);
    x = total_width + margin - self->folder.arrow_width;
    XtConfigureWidget(child, x, y, width, height, 0);

    child = GetStackWidget(self);
    x = margin;
    y = margin + self->folder.tab_height;
    width = total_width;
    height = total_height - self->folder.tab_height;
    XtConfigureWidget(child, x, y, width, height, 0);

    update_tabs_if_necessary(self);
}

static XtGeometryResult handle_layout(FolderWidget self, Widget requesting_child,
				      XtWidgetGeometry *desired, XtWidgetGeometry *allowed)
{
    XtWidgetGeometry desired_by_me;
    XtWidgetGeometry desired_by_child;
    XtWidgetGeometry allowed_by_parent;
    Dimension saved_width, saved_height;
    int margin_space;
    int i, r;

#define Wants(flag)	    (desired->request_mode & (flag))
#define RestoreGeometry()   do { self->core.width = saved_width; self->core.height = saved_height; } while (0)

    if (Wants(CWSibling | CWStackMode | CWBorderWidth)) return(XtGeometryNo);
    if (requesting_child != GetStackWidget(self) || Wants(CWX) || Wants(CWY)) return(XtGeometryYes);

    /* The requesting_child (the stack widget) is attempting to resize itself.
       We attempt to grant the width and/or height change. */

    desired_by_me.width = 0;
    desired_by_me.height = 0;

    saved_width = self->core.width;
    saved_height = self->core.height;

    margin_space = self->core.border_width * 2 + self->folder.outside_margin * 2;

    if (Wants(CWWidth)) desired_by_me.width = desired->width + margin_space;
    if (Wants(CWHeight)) desired_by_me.height = desired->height + margin_space + self->folder.tab_height;

    if (desired_by_me.width <= 0) desired_by_me.width = saved_width;
    if (desired_by_me.height <= 0) desired_by_me.height = saved_height;

    if (desired_by_me.width == saved_width && desired_by_me.height == saved_height) return(XtGeometryDone);

    desired_by_me.request_mode = CWWidth | CWHeight;
    if (Wants(XtCWQueryOnly)) desired_by_me.request_mode |= XtCWQueryOnly;

    while ((r = XtMakeGeometryRequest((Widget)self, &desired_by_me,
				      &allowed_by_parent)) == XtGeometryAlmost)
    {
	desired_by_me = allowed_by_parent;
    }

    if (r == XtGeometryNo)
    {
	RestoreGeometry();
	return(XtGeometryNo);
    }

    desired_by_me.width -= margin_space;
    desired_by_me.height -= margin_space + self->folder.tab_height;

    if ((!Wants(CWWidth) || desired_by_me.width == desired->width || 0 == desired->width) &&
	(!Wants(CWHeight) || desired_by_me.height == desired->height || 0 == desired->height))
    {
	if (Wants(XtCWQueryOnly))
	{
	    RestoreGeometry();
	    return(XtGeometryYes);
	}
	else
	{
	    Resize((Widget)self);
	    return(XtGeometryDone);
	}
    }

    RestoreGeometry();

    allowed->width = desired_by_me.width;
    allowed->height = desired_by_me.height;
    allowed->request_mode = CWWidth | CWHeight;

    return(XtGeometryAlmost);

#undef Wants
#undef RestoreGeometry

}

static XtGeometryResult GeometryManager(Widget requesting_child,
					XtWidgetGeometry *desired, XtWidgetGeometry *allowed)
{
    return(handle_layout((FolderWidget)XtParent(requesting_child), requesting_child, desired, allowed));
}

static void Realize(Widget w, XtValueMask *value_mask, XSetWindowAttributes *attributes)
{
    FolderWidget self = (FolderWidget)w;
    Dimension saved_width, saved_height, allowed_width, allowed_height;
    int r;

    folderWidgetClass->core_class.superclass->core_class.realize(w, value_mask, attributes);

    self->folder.tab_gc = XCreateGC(XtDisplay(w), XtWindow(w), 0, 0);
    XSetFont(XtDisplay(self), self->folder.tab_gc, self->folder.tab_font->fid);
    XSetLineAttributes(XtDisplay(self), self->folder.tab_gc, 2, LineSolid, CapButt, JoinBevel);

    create_arrow_pixmaps(self);

    XtVaSetValues(GetLeftArrowWidget(self),
		  XmNlabelPixmap, self->folder.left_arrow_pixmap,
		  0);

    XtVaSetValues(GetRightArrowWidget(self),
		  XmNlabelPixmap, self->folder.right_arrow_pixmap,
		  0);
}

static Boolean SetValues(Widget old_widget, Widget req_widget, Widget new_widget,
			 ArgList args, Cardinal *num_args)
{
    FolderWidget new_folder = (FolderWidget)new_widget;
    FolderWidget old_folder = (FolderWidget)old_widget;
    Boolean must_redisplay = False;

#define NE(f) (new_folder->folder.f != old_folder->folder.f)

    if (NE(tab_height))
    {
	compute_size(new_folder);
	must_redisplay = True;
    }

    if (NE(top_folder_color) || NE(bottom_folder_color) || NE(tab_font) ||
	NE(tab_alignment) || NE(tab_margin))
    {
	must_redisplay = True;
    }

    return(must_redisplay);
}

static void GetValuesHook(Widget w, ArgList args, Cardinal *num_args)
{
    FolderWidget self = (FolderWidget)w;
    int i;

    for (i = 0; i < *num_args; ++i)
    {
	if (strcmp(args[i].name, XtNstackWidget) == 0)
	{
	    *(Widget *)(args[i].value) = GetStackWidget(self);
	}
    }
}

static void Destroy(Widget w)
{
    FolderWidget self = (FolderWidget)w;

    if (self->folder.tab_gc) XFreeGC(XtDisplay(self), self->folder.tab_gc);
}

static void handle_tab_exposures(Widget w, XtPointer client, XEvent *event, Boolean *more)
{
    FolderWidget self = (FolderWidget)XtParent(w);

    redraw_tabs(self);
}

static void handle_tab_clicking(Widget w, XtPointer client, XEvent *event, Boolean *more)
{
    FolderWidget self = (FolderWidget)XtParent(w);
    StackWidget stack = (StackWidget)GetStackWidget(self);
    Widget child;
    StackConstraint layer_info;
    int start, stop;
    int i;

    if (event->type != ButtonRelease || event->xbutton.window != XtWindow(w)) return;

    for (i = 0; i < stack->composite.num_children; ++i)
    {
	child = stack->composite.children[i];

	if (XtIsManaged(child))
	{
	    layer_info = (StackConstraint)child->core.constraints;

	    start = layer_info->stack.tab_position - self->folder.current_tab_offset;
	    stop = start + layer_info->stack.tab_length - self->folder.tab_slant_width;

	    if (event->xbutton.x >= start && event->xbutton.x <= stop)
	    {
		StackGotoWidget((Widget)stack, i);
		return;
	    }
	}
    }
}

static void InsertChild(Widget w)
{
    FolderWidget self = (FolderWidget)XtParent(w);
    CompositeWidgetClass parent_class = (CompositeWidgetClass)stackWidgetClass->core_class.superclass;

    w->core.border_width = 0;

    parent_class->composite_class.insert_child(w);
}

static void DeleteChild(Widget w)
{
    FolderWidget self = (FolderWidget)XtParent(w);
    CompositeWidgetClass parent_class = (CompositeWidgetClass)stackWidgetClass->core_class.superclass;

    parent_class->composite_class.delete_child(w);
}

static void scroll_left(Widget w, XtPointer client_data, XtPointer call_data)
{
    FolderWidget self = (FolderWidget)client_data;
    StackWidget stack = (StackWidget)GetStackWidget(self);
    Widget child;
    StackConstraint layer_info;
    int position;
    int last_position = 0;
    int i;

    for (i = 0; i < stack->composite.num_children; ++i)
    {
	child = stack->composite.children[i];

	if (XtIsManaged(child))
	{
	    layer_info = (StackConstraint)child->core.constraints;
	    position = layer_info->stack.tab_position - self->folder.current_tab_offset;

	    if (position >= 0) break;
	    last_position = position;
	}
    }

    if (last_position != 0)
    {
	self->folder.current_tab_offset += last_position - self->folder.tab_margin * 3;
    }
    
    update_tabs_if_necessary(self);
}

static void scroll_right(Widget w, XtPointer client_data, XtPointer call_data)
{
    FolderWidget self = (FolderWidget)client_data;
    StackWidget stack = (StackWidget)GetStackWidget(self);
    Widget tabs = GetTabsWidget(self);
    Widget child;
    StackConstraint layer_info;
    int position;
    int last_position = 0;
    int i;

    for (i = stack->composite.num_children - 1; i >= 0; --i)
    {
	child = stack->composite.children[i];

	if (XtIsManaged(child))
	{
	    layer_info = (StackConstraint)child->core.constraints;
	    position = layer_info->stack.tab_position +
		layer_info->stack.tab_length - self->folder.current_tab_offset;

	    if (position <= tabs->core.width) break;
	    last_position = position;
	}
    }

    if (last_position != 0)
    {
	if (self->folder.current_tab_offset <= 0)
	{
	    self->folder.current_tab_offset += self->folder.arrow_width + 1;
	}

	self->folder.current_tab_offset += last_position - tabs->core.width;
    }
    
    update_tabs_if_necessary(self);
}

static void Initialize(Widget req_widget, Widget new_widget, ArgList args, Cardinal *num_args)
{
    FolderWidget self = (FolderWidget)new_widget;
    Widget parent = XtParent(self);
    Dimension margin = self->core.border_width + self->folder.outside_margin;
    Widget w;

    self->folder.tab_gc = 0;
    self->folder.left_arrow_pixmap = 0;
    self->folder.right_arrow_pixmap = 0;
    self->folder.need_left_arrow = False;
    self->folder.need_right_arrow = False;
    self->folder.arrow_width = ARROW_WIDTH * 2;
    self->folder.current_tab_offset = 0;

    if (self->folder.tab_height == 0)
    {
	self->folder.tab_height = (self->folder.tab_font->ascent + self->folder.tab_font->descent) * 3 + 1;
    }

    if (self->folder.tab_slant_width == 0)
    {
	self->folder.tab_slant_width = self->folder.tab_height / 2;
    }

#define DEFAULT_WIDTH 200

    w = XtVaCreateManagedWidget("stack", stackWidgetClass, new_widget,
				XtNx, margin,
				XtNy, margin + self->folder.tab_height,
				XtNwidth, DEFAULT_WIDTH,
				XtNheight, 400,
				XtNborderWidth, 0,
				0);

    w = XtVaCreateManagedWidget("tabs", coreWidgetClass, new_widget,
				XtNx, margin,
				XtNy, margin,
				XtNwidth, DEFAULT_WIDTH - self->folder.arrow_width * 2,
				XtNheight, self->folder.tab_height,
				XtNborderWidth, 0,
				XtNbackground, self->core.background_pixel,
				0);

    XtAddEventHandler(w, ExposureMask, False, handle_tab_exposures, 0);
    XtAddEventHandler(w, ButtonReleaseMask, False, handle_tab_clicking, 0);

    w = XtVaCreateManagedWidget("left_arrow", xmPushButtonWidgetClass, new_widget,
				XtNx, margin,
				XtNy, margin,
				XtNwidth, self->folder.arrow_width,
				XtNheight, self->folder.tab_height,
				XtNborderWidth, 0,
				XtNbackground, self->core.background_pixel,
				XmNlabelType, XmPIXMAP,
				XmNrecomputeSize, False,
				XtNmappedWhenManaged, False,
				0);

    XtAddCallback(w, XmNactivateCallback, scroll_left, self);

    w = XtVaCreateManagedWidget("right_arrow", xmPushButtonWidgetClass, new_widget,
				XtNx, DEFAULT_WIDTH + margin - ARROW_WIDTH * 2,
				XtNy, margin,
				XtNwidth, self->folder.arrow_width,
				XtNheight, self->folder.tab_height,
				XtNborderWidth, 0,
				XtNbackground, self->core.background_pixel,
				XmNlabelType, XmPIXMAP,
				XmNrecomputeSize, False,
				XtNmappedWhenManaged, False,
				0);

    XtAddCallback(w, XmNactivateCallback, scroll_right, self);

    compute_size(self);
}

/* Class record declaration */

FolderClassRec folderClassRec =
{
    /* Core class part */

    {
	/* superclass               */ (WidgetClass)&xmManagerClassRec,
	/* class_name               */ "Folder",
	/* widget_size              */ sizeof(FolderRec),
	/* class_initialize         */ 0,
	/* class_part_initialize    */ 0,
	/* class_inited             */ False,
	/* initialize               */ Initialize,
	/* initialize_hook          */ 0,
	/* realize                  */ Realize,
	/* actions                  */ 0,
	/* num_actions              */ 0,
	/* resources                */ resources,
	/* num_resources            */ XtNumber(resources),
	/* xrm_class                */ NULLQUARK,
	/* compress_motion          */ True,
	/* compress_exposure        */ XtExposeCompressMultiple,
	/* compress_enterleave      */ True,
	/* visible_interest         */ False,
	/* destroy                  */ Destroy,
	/* resize                   */ Resize,
	/* expose                   */ 0,
	/* set_values               */ SetValues,
	/* set_values_hook          */ 0,
	/* set_values_almost        */ XtInheritSetValuesAlmost,
	/* get_values_hook          */ GetValuesHook,
	/* accept_focus             */ XtInheritAcceptFocus,
	/* version                  */ XtVersion,
	/* callback offsets         */ 0,
	/* tm_table                 */ 0,
	/* query_geometry           */ XtInheritQueryGeometry,
	/* display_accelerator      */ 0,
	/* extension                */ 0
    },

    /* Composite Part */

    {
	/* geometry_manager         */ GeometryManager,
	/* change_managed           */ 0,
	/* insert_child             */ InsertChild,
	/* delete_child             */ DeleteChild,
	/* extension                */ 0
    },

    /* Constraint Part */

    {
	/* resources                */ 0,
	/* num_resources            */ 0,
	/* constraint_size          */ 0,
	/* initialize               */ 0,
	/* destroy                  */ 0,
	/* set_values               */ 0,
	/* extension                */ 0
    },

    /* Manager Part */

    {
	XtInheritTranslations,
	0,
	0,
	0,
	0,
	XmInheritParentProcess,
	0
    },

    /* Folder class part */

    {
	/* example so I remember...  */ 0
    }
};

/* Class record pointer */

WidgetClass folderWidgetClass = (WidgetClass)&folderClassRec;

void FolderRedisplayTabsNotify(Widget folder)
{
    FolderWidget self = (FolderWidget)folder;

    update_tabs_if_necessary(self);
}

void FolderTabsChangedNotify(Widget folder)
{
    FolderWidget self = (FolderWidget)folder;
    StackWidget stack = (StackWidget)GetStackWidget(self);
    XFontStruct *fs = self->folder.tab_font;
    Widget child;
    StackConstraint layer_info;
    String p, name_1, name_2;
    int length_1, length_2;
    Dimension text_width, text_height;
    Dimension current_position = self->folder.tab_margin * 3;
    int i;

    for (i = 0; i < stack->composite.num_children; ++i)
    {
	child = stack->composite.children[i];

	if (XtIsManaged(child))
	{
	    layer_info = (StackConstraint)child->core.constraints;

	    if (layer_info->stack.layer_name == 0)
	    {
		if (child->core.name)
		{
		    layer_info->stack.layer_name = XtNewString(child->core.name);
		}
		else
		{
		    char buffer[32];
		    sprintf(buffer, "%d", i);
		    layer_info->stack.layer_name = XtNewString(buffer);
		}
	    }

	    p = layer_info->stack.layer_name;

	    name_1 = p;
	    while (*p != 0 && *p != '\n') ++p;
	    length_1 = p - name_1;

	    if (*p != 0) ++p;

	    name_2 = p;
	    while (*p != 0 && *p != '\n') ++p;
	    length_2 = p - name_2;

	    text_width = max(XTextWidth(fs, name_1, length_1),
			     XTextWidth(fs, name_2, length_2));

	    text_height = fs->max_bounds.ascent + fs->max_bounds.descent;
	    if (length_2) text_height += text_height + 1;
	    else text_height += fs->max_bounds.descent / 2;

	    layer_info->stack.tab_position = current_position;

	    layer_info->stack.tab_length = text_width + self->folder.tab_margin * 2 +
		fs->max_bounds.ascent + self->folder.tab_slant_width;

	    layer_info->stack.tab_starting_line = self->folder.tab_margin +
						   (self->folder.tab_height -
						    self->folder.tab_margin -
						    text_height) / 2 + fs->max_bounds.ascent + 1;

	    layer_info->stack.name_1 = name_1;
	    layer_info->stack.length_1 = length_1;
	    layer_info->stack.name_2 = name_2;
	    layer_info->stack.length_2 = length_2;

	    current_position += layer_info->stack.tab_length - (int)(self->folder.tab_slant_width * 0.75);
	}
    }
}
