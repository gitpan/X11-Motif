
#ifndef _FOLDERP_H
#define _FOLDERP_H

#include "Folder.h"

/* Define the Folder instance part */

typedef struct
{
    /* New resource fields */

    Dimension outside_margin;
    String tab_position;
    String tab_alignment;
    Boolean allow_scrolling_tabs;
    Dimension tab_height;
    Dimension tab_slant_width;
    Dimension tab_margin;
    XFontStruct *tab_font;
    Pixel foreground;
    Pixel top_folder_color;
    Pixel bottom_folder_color;

    /* New internal fields */

    GC tab_gc;
    Pixmap left_arrow_pixmap;
    Pixmap right_arrow_pixmap;
    Dimension arrow_width;
    Boolean need_left_arrow;
    Boolean need_right_arrow;
    unsigned int current_tab_offset;
}
FolderPart;

/* Define the full instance record */

typedef struct _FolderRec
{
    CorePart core;
    CompositePart composite;
    ConstraintPart constraint;
    XmManagerPart manager;
    FolderPart folder;
}
FolderRec, *FolderWidget;

/* Define class part structure */

typedef struct _FolderClassPart
{
    int likeThis;
}
FolderClassPart;

typedef struct _FolderClassRec
{
    CoreClassPart core_class;
    CompositeClassPart composite_class;
    ConstraintClassPart constraint_class;
    XmManagerClassPart manager_class;
    FolderClassPart folder_class;
}
FolderClassRec;

/* External definition for class record */

extern FolderClassRec folderClassRec;

#endif /* _FOLDERP_H */
