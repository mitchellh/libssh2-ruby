#ifndef LIBSSH2_RUBY_H
#define LIBSSH2_RUBY_H

#include <ruby.h>
#include <libssh2.h>

/*
 * Makes the otherwise non-blocking libssh2 method call
 * a blocking call by waiting for it.
 * */
#define BLOCK(stmt) while ((stmt) == LIBSSH2_ERROR_EAGAIN)

extern VALUE rb_mLibSSH2;
extern VALUE rb_mLibSSH2_Native;
extern VALUE rb_cLibSSH2_Native_Session;

/*
 * The struct embedded with LibSSH2::Native::Session classes
 * to store our internal C data.
 * */
typedef struct {
    LIBSSH2_SESSION *session;
} LibSSH2_Ruby_Session;

void init_libssh2_global();
void init_libssh2_session();

#endif
