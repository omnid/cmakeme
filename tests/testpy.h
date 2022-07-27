#ifndef TEST_H_INCLUDE_GUARD
#define TEST_H_INCLUDE_GUARD
/// \file
/// \brief A test C function to be called from python

/// \brief the maximum length of the string
#define STR_MAX_LEN 10

/// \brief Track the string and it's length, max length 10
struct StrLen
{
    char data[STR_MAX_LEN];
    int length;
};

/// \brief retrieve the length of the string
/// \param str data should be a null terminated string
/// \return the length of the string, or 10 if not null terminated
int get_length(struct StrLen str);

/// \brief update the length of the string
/// \param str data should be a null terminated string
/// \return true if the string was null terminated
bool update_length(struct StrLen *);
