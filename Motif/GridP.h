
#ifndef GRIDP_H
#define GRIDP_H

#include "Grid.h"

/* Define the Grid instance part */

typedef struct
{
    /* New resource fields */

    Dimension space;		/* space to leave around the border of an element */
    int rows;			/* The number of rows in the longest column */
    Dimension elementHeight;	/* calculated height of an element */
    Pixel foreground;		/* default element foreground color */
    XFontStruct *font;		/* default element font */
    int colorAltRows;		/* if > 0, then color alternate blocks of N rows */
    int firstColoredRow;	/* when coloring rows, this is the row to start on */
    Pixel altBackground;	/* color of background used in alternate rows */

    /* New internal fields */

    Boolean safeToUpdate;	/* should update when switching columns or updating */
    Dimension desiredWidth;	/* width the widget would *like* to be */
    GridColumn *column;		/* list of columns being displayed */
    GC defaultGC;		/* GC for drawing column data */
    GC shadingGC;		/* GC for drawing column background and highlights */
    int topRow;			/* row number of first row displayed */
    int leftMargin;		/* pixel offset of the left margin after scrolling */
    Widget hScroll;		/* scroll bars used when embedded in a scrolling window */
    Widget vScroll;
}
GridPart;

/* Define the full instance record */

typedef struct _GridRec
{
    CorePart core;
    XmPrimitivePart primitive;
    GridPart grid;
}
GridRec, *GridWidget;

/* Define class part structure */

typedef struct
{
    int likeThis;
}
GridClassPart;

/* Define the full class record */

typedef struct _GridClassRec
{
    CoreClassPart core_class;
    XmPrimitiveClassPart primitive_class;
    GridClassPart grid_class;
}
GridClassRec, *GridWidgetClass;

/* External definition for class record */

extern GridClassRec gridClassRec;

#endif
