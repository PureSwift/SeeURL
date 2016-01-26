//
//  cURLSwift.h
//  SeeURL
//
//  Created by Alsey Coleman Miller on 1/25/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

#include <curl/curl.h>
#include <stdbool.h>
#include <stdio.h>

#define CURL_INLINE static __inline__

typedef size_t (*curl_func)(char * ptr, size_t size, size_t num, void * ud);

CURL_INLINE CURLcode curl_easy_setopt_string(CURL *curl, CURLoption option, const char *param) {
    return curl_easy_setopt(curl, option, param);
}

CURL_INLINE CURLcode curl_easy_setopt_bool(CURL *curl, CURLoption option, bool param) {
    return curl_easy_setopt(curl, option, param);
}

CURL_INLINE CURLcode curl_easy_setopt_func(CURL *handle, CURLoption option, curl_func param)
{
    return curl_easy_setopt(handle, option, param);
}

CURL_INLINE CURLcode curl_easy_setopt_pointer(CURL *handle, CURLoption option, const void* param)
{
    return curl_easy_setopt(handle, option, param);
}

CURL_INLINE CURLcode curl_easy_setopt_long(CURL *curl, CURLoption option, long param) {
    return curl_easy_setopt(curl, option, param);
}

CURL_INLINE CURLcode curl_easy_setopt_slist(CURL *curl, CURLoption option, struct curl_slist *param) {
    return curl_easy_setopt(curl, option, param);
}

CURL_INLINE CURLcode curl_easy_getinfo_long(CURL *handle, CURLINFO option, long *param)
{
    return curl_easy_getinfo(handle, option, param);
}

CURL_INLINE CURLcode curl_easy_getinfo_string(CURL *handle, CURLINFO option, const char **param)
{
    return curl_easy_getinfo(handle, option, param);
}

CURL_INLINE CURLcode curl_easy_getinfo_double(CURL *handle, CURLINFO option, double *param)
{
    return curl_easy_getinfo(handle, option, param);
}

CURL_INLINE CURLcode curl_easy_getinfo_slist(CURL *handle, CURLINFO option, struct curl_slist **param)
{
    return curl_easy_getinfo(handle, option, param);
}

/** Public interface for FormAdd() */
static
CURLFORMcode FormAdd(struct curl_httppost **httppost,
                     struct curl_httppost **last_post,
                     va_list params);

