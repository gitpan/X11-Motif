
#ifndef _STACKP_H
#define _STACKP_H

#include "Stack.h"

/* Define the Stack instance part */

typedef struct
{
    /* New resource fields */

    Dimension outside_margin;
    XtCallbackList now_displayed_cb;
    XtCallbackList now_hidden_cb;

    /* New internal fields */

    int active_child;
    int last_active_child;
}
StackPart;

/* Define the full instance record */

typedef struct _StackRec
{
    CorePart core;
    CompositePart composite;
    ConstraintPart constraint;
    XmManagerPart manager;
    StackPart stack;
}
StackRec, *StackWidget;

/* Define class part structure */

typedef struct _StackClassPart
{
    int likeThis;
}
StackClassPart;

typedef struct _StackClassRec
{
    CoreClassPart core_class;
    CompositeClassPart composite_class;
    ConstraintClassPart constraint_class;
    XmManagerClassPart manager_class;
    StackClassPart stack_class;
}
StackClassRec;

typedef struct _StackConstraintPart
{
    String layer_name;
    Boolean layer_active;

    Dimension tab_position;
    Dimension tab_length;
    Dimension tab_starting_line;

    String name_1;
    int length_1;
    String name_2;
    int length_2;
}
StackConstraintPart;

typedef struct _StackConstraintRec
{
    StackConstraintPart stack;
}
StackConstraintRec, *StackConstraint;

/* External definition for class record */

extern StackClassRec stackClassRec;

#endif /* _STACKP_H */
