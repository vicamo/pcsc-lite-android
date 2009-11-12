/*
 * MUSCLE SmartCard Development ( http://www.linuxnet.com )
 *
 * Copyright (C) 1999-2002
 *  David Corcoran <corcoran@linuxnet.com>
 * Copyright (C) 2002-2009
 *  Ludovic Rousseau <ludovic.rousseau@free.fr>
 *
 * $Id$
 */

/**
 * @file
 * @brief This abstracts dynamic library loading functions and timing.
 */

#include "config.h"
#include <stdio.h>
#include <string.h>
#if defined(HAVE_DLFCN_H) && !defined(HAVE_DL_H) && !defined(__APPLE__)
#include <dlfcn.h>
#include <stdlib.h>

#include "misc.h"
#include "pcsclite.h"
#include "debug.h"
#include "dyn_generic.h"

INTERNAL int DYN_LoadLibrary(void **pvLHandle, char *pcLibrary)
{
	*pvLHandle = NULL;
	*pvLHandle = dlopen(pcLibrary, RTLD_LAZY);

	if (*pvLHandle == NULL)
	{
		Log3(PCSC_LOG_CRITICAL, "%s: %s", pcLibrary, dlerror());
		return SCARD_F_UNKNOWN_ERROR;
	}

	return SCARD_S_SUCCESS;
}

INTERNAL int DYN_CloseLibrary(void **pvLHandle)
{
	int ret;

	ret = dlclose(*pvLHandle);
	*pvLHandle = NULL;

	if (ret)
	{
		Log2(PCSC_LOG_CRITICAL, "%s", dlerror());
		return SCARD_F_UNKNOWN_ERROR;
	}

	return SCARD_S_SUCCESS;
}

INTERNAL int DYN_GetAddress(void *pvLHandle, void **pvFHandle, const char *pcFunction)
{
	char pcFunctionName[256];
	int rv;

	/* Some platforms might need a leading underscore for the symbol */
	(void)snprintf(pcFunctionName, sizeof(pcFunctionName), "_%s", pcFunction);

	*pvFHandle = NULL;
	*pvFHandle = dlsym(pvLHandle, pcFunctionName);

	/* Failed? Try again without the leading underscore */
	if (*pvFHandle == NULL)
		*pvFHandle = dlsym(pvLHandle, pcFunction);

	if (*pvFHandle == NULL)
	{
		Log3(PCSC_LOG_CRITICAL, "%s: %s", pcFunction, dlerror());
		rv = SCARD_F_UNKNOWN_ERROR;
	} else
		rv = SCARD_S_SUCCESS;

	return rv;
}

#endif	/* HAVE_DLFCN_H && !HAVE_DL_H && !__APPLE__ */
