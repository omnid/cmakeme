#include "testpy.h"
#include<stdio.h>

int get_length(struct StrLen str)
{
    int i = 0;
    for(i = 0; i != STR_MAX_LEN; ++i)
    {
        if(str.data[i] == '\0')
        {
            break;
        }
    }
    return i;
}

bool update_length(struct StrLen * str)
{
    if(!str)
    {
        printf("Error, string is NULL\n");
    }
    str->length = get_length(*str);
    return str->length < STR_MAX_LEN;
}
